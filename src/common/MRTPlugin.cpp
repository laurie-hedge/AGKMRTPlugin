#include <cstdio>
#include <Windows.h>
#include <gl/GL.h>
#include "glext.h"
#include "cImage.h"
#include "AGKLibraryCommands.h"

enum ErrorMode {
	ERROR_MODE_IGNORE = 0,
	ERROR_MODE_REPORT_FIRST,
	ERROR_MODE_REPORT_ALL,
	ERROR_MODE_STOP
};

enum PluginState {
	PLUGIN_STATE_UNINITIALISED,
	PLUGIN_STATE_READY,
	PLUGIN_STATE_UNSUPPORTED
};

PFNGLFRAMEBUFFERTEXTUREPROC glFramebufferTexture;
PFNGLDRAWBUFFERSPROC glDrawBuffers;
PFNGLCHECKFRAMEBUFFERSTATUSPROC glCheckFramebufferStatus;

ErrorMode errorMode = ERROR_MODE_REPORT_FIRST;
PluginState pluginState = PLUGIN_STATE_UNINITIALISED;
unsigned int maxRenderTargets;
unsigned int numAttachmentsActive;
GLenum *attachPoints = NULL;
unsigned int *renderImages = NULL;
bool errorReported;

void PluginError(char const *format, ...)
{
	if (ERROR_MODE_IGNORE == errorMode) {
		return;
	}

	if (errorReported) {
		if (ERROR_MODE_REPORT_FIRST == errorMode) {
			return;
		}
	}
	else {
		errorReported = true;
	}

	char *str = agk::CreateString(512);

	va_list args;
	va_start(args, format);

	vsnprintf(str, 512, format, args);
	agk::PluginError(str);

	va_end(args);

	if (ERROR_MODE_STOP == errorMode) {
		exit(-1);
	}
}

void UnattachAllTextures()
{
	for (unsigned int i = 0; i < numAttachmentsActive; ++i) {
		if (GL_NONE != attachPoints[i]) {
			glFramebufferTexture(GL_FRAMEBUFFER, attachPoints[i], 0, 0);
		}
	}
}

bool CheckInit()
{
	switch (pluginState) {
	case PLUGIN_STATE_UNINITIALISED: {
		GLint majorVersion = 0, minorVersion = 0;
		glGetIntegerv(GL_MAJOR_VERSION, &majorVersion);
		glGetIntegerv(GL_MINOR_VERSION, &minorVersion);
		if (majorVersion < 3 || (3 == majorVersion && minorVersion < 2)) {
			pluginState = PLUGIN_STATE_UNSUPPORTED;
			return false;
		}

		glFramebufferTexture = (PFNGLFRAMEBUFFERTEXTUREPROC)wglGetProcAddress("glFramebufferTexture");
		glDrawBuffers = (PFNGLDRAWBUFFERSPROC)wglGetProcAddress("glDrawBuffers");
		glCheckFramebufferStatus = (PFNGLCHECKFRAMEBUFFERSTATUSPROC)wglGetProcAddress("glCheckFramebufferStatus");
		if (!glFramebufferTexture || !glDrawBuffers || !glCheckFramebufferStatus) {
			pluginState = PLUGIN_STATE_UNSUPPORTED;
			return false;
		}

		GLint maxColourAttachments = 0, maxDrawBuffers = 0;
		glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColourAttachments);
		glGetIntegerv(GL_MAX_DRAW_BUFFERS, &maxDrawBuffers);
		maxRenderTargets = (unsigned int)(maxColourAttachments < maxDrawBuffers ? maxColourAttachments : maxDrawBuffers);
		if (maxRenderTargets < 2) {
			pluginState = PLUGIN_STATE_UNSUPPORTED;
			return false;
		}

		attachPoints = new GLenum[maxRenderTargets];
		renderImages = new unsigned int[maxRenderTargets];

		for (unsigned int i = 0; i < maxRenderTargets; ++i) {
			attachPoints[i] = GL_NONE;
		}
		numAttachmentsActive = 0;

		pluginState = PLUGIN_STATE_READY;
		errorReported = false;

		return true;
	}

	case PLUGIN_STATE_READY:
		return true;

	case PLUGIN_STATE_UNSUPPORTED:
		return false;
	}

	return false;
}

extern "C"
{
	DLL_EXPORT void MRT_SetErrorMode(int mode)
	{
		switch (mode) {
			case ERROR_MODE_IGNORE:
			case ERROR_MODE_REPORT_FIRST:
			case ERROR_MODE_REPORT_ALL:
			case ERROR_MODE_STOP:
				errorMode = (ErrorMode)mode;
				break;

			default:
				PluginError("Invalid error mode %d.", mode);
				break;
		}
	}

	DLL_EXPORT int MRT_IsSupportedMRT()
	{
		CheckInit();

		if (PLUGIN_STATE_UNSUPPORTED == pluginState) {
			return 0;
		}
		return 1;
	}

	DLL_EXPORT int MRT_GetMaxRenderImages()
	{
		if (!CheckInit()) {
			return 0;
		}

		return maxRenderTargets;
	}

	DLL_EXPORT void MRT_SetRenderImage(unsigned int attachPoint, unsigned int renderImage)
	{
		if (!CheckInit()) {
			return;
		}

		if (attachPoint >= (unsigned int)maxRenderTargets) {
			PluginError("Invalid attachment point %u. Max render targets is %u.", attachPoint, maxRenderTargets);
			return;
		}

		if (renderImage) {
			if (attachPoint >= numAttachmentsActive) {
				numAttachmentsActive = attachPoint + 1;
			}
			attachPoints[attachPoint] = GL_COLOR_ATTACHMENT0 + attachPoint;
			renderImages[attachPoint] = renderImage;
		}
		else {
			attachPoints[attachPoint] = GL_NONE;
			while (numAttachmentsActive > 0 && GL_NONE == attachPoints[numAttachmentsActive - 1]) {
				numAttachmentsActive -= 1;
			}
		}
	}

	DLL_EXPORT void MRT_ClearRenderImages()
	{
		if (!CheckInit()) {
			return;
		}

		for (unsigned int i = 0; i < numAttachmentsActive; ++i) {
			attachPoints[i] = GL_NONE;
		}
		numAttachmentsActive = 0;
	}

	DLL_EXPORT void MRT_SetRenderToMRT()
	{
		if (!CheckInit()) {
			return;
		}

		if (0 == numAttachmentsActive) {
			PluginError("Trying to render to MRT without setting any render targets. At least one render target is required.");
			return;
		}

		unsigned int firstImage = 0;
		unsigned int renderWidth, renderHeight;

		for (unsigned int i = 0; i < numAttachmentsActive; ++i) {
			if (GL_NONE != attachPoints[i]) {
				bool needsAttachment = true;

				AGK::cImage *image = agk::GetImagePtr(renderImages[i]);
				if (!image) {
					PluginError("Unknown render image %u.", renderImages[i]);
					UnattachAllTextures();
					return;
				}

				if (0 == firstImage) {
					agk::SetRenderToImage(renderImages[i], 0);
					renderWidth = image->m_iOrigWidth;
					renderHeight = image->m_iOrigHeight;
					needsAttachment = (GL_COLOR_ATTACHMENT0 != attachPoints[i]);
					firstImage = renderImages[i];
				}
				else {
					if (renderWidth != image->m_iOrigWidth || renderHeight != image->m_iOrigHeight) {
						PluginError("Trying to render to MRT with mismatched render image sizes. Image %u is of size %ux%u, but image %u is of size %ux%u.", firstImage, renderWidth, renderHeight, renderImages[i], image->m_iOrigWidth, image->m_iOrigHeight);
						UnattachAllTextures();
						return;
					}
				}

				if (needsAttachment) {
					glFramebufferTexture(GL_FRAMEBUFFER, attachPoints[i], image->m_iTextureID, 0);
					switch (glGetError()) {
						case GL_INVALID_ENUM:
						case GL_INVALID_OPERATION: {
							PluginError("Failed to set framebuffer attachment. Invalid target.");
							UnattachAllTextures();
							return;
						}
						case GL_INVALID_VALUE: {
							PluginError("Failed to set framebuffer attachment. Invalid render image %u.", renderImages[i]);
							UnattachAllTextures();
							return;
						}
					}
				}
			}
		}

		glDrawBuffers(numAttachmentsActive, attachPoints);
		switch (glGetError()) {
			case GL_INVALID_ENUM: {
				PluginError("Failed to set draw buffers. Invalid attachment set.");
				UnattachAllTextures();
				return;
			}
			case GL_INVALID_OPERATION: {
				PluginError("Failed to set draw buffers. Invalid attach point detected.");
				UnattachAllTextures();
				return;
			}
			case GL_INVALID_VALUE: {
				PluginError("Failed to set draw buffers. Invalid attach point detected. Max render targets is %u.", maxRenderTargets);
				UnattachAllTextures();
				return;
			}
		}

		switch (glCheckFramebufferStatus(GL_FRAMEBUFFER)) {
			case GL_FRAMEBUFFER_UNDEFINED: {
				PluginError("Trying to use the default framebuffer but it does not exist.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: {
				PluginError("Framebuffer attachment is incomplete.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: {
				PluginError("Framebuffer missing render target. At least one render target is required.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: {
				PluginError("Draw buffer incomplete.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: {
				PluginError("Read buffer incomplete.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_UNSUPPORTED: {
				PluginError("Incompatable render targets detected.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: {
				PluginError("Inconsistent multisampling across render targets.");
				UnattachAllTextures();
				return;
			}
			case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: {
				PluginError("Inconsistent layers across render targets.");
				UnattachAllTextures();
				return;
			}
		}
	}
}
