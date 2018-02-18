# AppGameKit Multiple Render Targets Plugin #

## Overview ##

Multiple render targets is a feature of OpenGL that allows you to write to multiple render images from a single fragment
shader. This can be used to preserve information about a fragment in addition to its colour, which can then be used in
later render passes to add additional effects.

To preserve maximum cross platform compatibility, AppGameKit uses a very old version of OpenGL, which does not have MRT
support. However if you are on a desktop platform, you almost certainly do have MRT support, which this plugin exposes.
However it is always worth using the IsSupportedMRT command to ensure that the platform you're running on does
actually support MRTs before you try to use them.

This plugin is provided freely for commercial and non-commercial use. The source code is available on
[GitHub](https://github.com/laurie-hedge/AGKMRTPlugin) under the MIT license.

## Installation ##

### Windows ###

Copy the MRT folder alongside this file into the AppGameKit plugins folder. If you installed AppGameKit through Steam,
this would typically be something like:
> C:\Program Files (x86)\Steam\steamapps\common\App Game Kit 2\Tier 1\Compiler\Plugins

### macOS ###

Copy the MRT folder alongside this file into the AppGameKit plugins folder. If you installed AppGameKit through Steam,
the app file would typically be located somewhere like:
> /Users/<username>/Library/Application Support/Steam/steamapps/common/App Game Kit 2

Once you've found the AppGameKit.app file, right click and select Show Package Contents to open is as a folder. Inside,
the plugins folder is located at:
> Contents/Resources/share/application/Plugins

### Linux ###

Copy the MRT folder alongside this file into the AppGameKit plugins folder. If you installed AppGameKit through Steam,
this would typically be something like:
> /home/<username>/.steam/steam/steamapps/common/App Game Kit 2/Tier1/Compiler/Plugins

## Usage ##

Once installed, to start using the plugin, you need to import it using the import_plugin directive somewhere in your
project.
`#import_plugin MRT`

You can then call any of the functions documented here. Typically you should start by checking that MRTs are supported
on the platform.
```
if not MRT.IsSupportedMRT()
	Message("Sorry, MRT is not supported on your machine.")
	end
endif
```

You can then create your render images using AppGameKit's own CreateRenderImage command, and set them up for rendering
using the SetRenderImage command.
```
img0 = CreateRenderImage(GetDeviceWidth(), GetDeviceHeight(), 0, 0)
img1 = CreateRenderImage(GetDeviceWidth(), GetDeviceHeight(), 0, 0)

MRT.SetRenderImage(0, img0)
MRT.SetRenderImage(1, img1)
```

Your scene can be setup as normal, using all of AppGameKit's Sprite, Text, and Object commands. However in order to
write to multiple render images, you will need to write a custom fragment shader. Instead of writing your output to
gl_FragColor as normal, instead, write the output to gl_FragData[x], where x is the attach point specified for the
specific render image. For example, a simple sprite shader that outputs its texture to the render image at attach point
0 and its colour to the image at attach point 1 would look like this.
```
uniform sampler2D texture0;
varying mediump vec2 uvVarying;
varying mediump vec4 colorVarying;
 
void main()
{
    gl_FragData[0] = texture2D(texture0, uvVarying);
    gl_FragData[1] = colorVarying;
}
```

Once the scene is ready, the SetRenderToMRT command can be used to start rendering to the render images specified.
Drawing the scene is then performed as normal.
```
MRT.SetRenderToMRT()
ClearScreen()
Render()
```

For a full example application, see the example folder alongside this file.

## Commands ##

### ClearRenderImages ###

`MRT.ClearRenderImages()`

Unattach all render images set using SetRenderImage.

This is the same as calling SetRenderTarget with 0 for the renderImage for each attachPoint set. After this call, you
will need to attach some new render images again before you can successully call SetRenderToMRT.

### GetMaxRenderImages ###

`integer MRT.GetMaxRenderImages()`

Returns the maximum number of render images than can be attached at any one time. It also defines one above the top
attachment point index, so if it returned 8, then the valid attachment points would be 0-7. Attachment points are used
in the SetRenderImage command.

### IsSupportedMRT ###

`integer MRT.IsSupportedMRT()`

Returns 1 if the platform support multiple render targets, and 0 if it does not.

Running other MRT commands on a platform without MRT support will do nothing. Therefore your app will continue to run
but may not behave correctly, so you may wish to branch on this result to provide an alternative rendering path for
platforms that don't provide multiple render targets.

### SetErrorMode ###

`MRT.SetErrorMode(mode)`

Set how the plugin handles errors. This needs to be done separately from AppGameKit's own SetErrorMode function as
AppGameKit doesn't apply the same rules to plugin errors.

The following values are valid error modes. By default, error mode 1 is used.

| Mode | Name         | Behaviour                                                                                      |
|:----:|:------------:|:----------------------------------------------------------------------------------------------:|
| 0    | Ignore       | Ignore errors and carry on. In most cases, the command will simply return after the error      |
|      |              | occurs. Silently ignoring errors is generally undesirable during development, but you may wish |
|      |              | to use this mode for the version to release to customers so that they never see errors.        |
| 1    | Report First | Report the first error to occur using AppGameKit's default error handling, which usually       |
|      |              | displays a native dialogue box with the error message. After the first error, other errors are |
|      |              | ignored silently until the app restarts. This can be desirable if the error occurs every frame |
|      |              | so that the app does not spam message boxes and make itself difficult to close in the case of  |
|      |              | an error.                                                                                      |
| 2    | Report All   | Report all errors using AppGameKit's default error handling, which usually displays a native   |
|      |              | dialogue box with the error message.                                                           |
| 3    | Stop         | Report the first error to occur using AppGameKit's default error handling, which usually       |
|      |              | displays a native dialogue box with the error message. Once the dialogue is closed, the app    |
|      |              | will close immediately.                                                                        |

### SetRenderImage ###

`MRT.SetRenderImage(attachPoint, renderImage)`

Attach the render image specified by renderImage to the attach point specified by attachPoint in preparation for an MRT
render.

renderImage should either be the ID of an image created with the CreateRenderImage command, or 0 to remove an image
already attached at attachPoint.

attachPoint is an integer in the range of 0..GetMaxRenderImages()-1. These numbers don't have to be specified
contiguously, so you can miss out indices if you don't wish to use them. The index specified here is the one you will
use as the index into gl_FragData in your shader to write to this image. For example, to write to img1, you could bind
the image to attach point 3.
`MRT.SetRenderImage(3, img1)`
Then in your glsl, you would write to this image by using index 3 of gl_FragData.
`gl_FragData[3] = vec4(1.0, 0.0, 0.0, 1.0);`

The image will not actually be attached and used until the SetRenderToMRT command is called.

### SetRenderToMRT ###

`MRT.SetRenderToMRT()`

Setup the render images specified using SetRenderImage for rendering. All rendering commands after this will be drawn to
the render images specified before it was called. To change the render images, use SetRenderImage and then call
SetRenderToMRT again. To go back to AppGameKit's normal rendering, you can simply use AppGameKit's SetRenderToImage or
SetRenderToScreen commands.

It is good practise to call ClearScreen after this command.

At the point that this is called, there must be at least one render image set, and all of the attached render images
should be of the same size.
