// Import the plugin.
#import_plugin MRT

// Setup error handling.
SetErrorMode(2)
MRT.SetErrorMode(3)

// Check that MRT is supported.
if not MRT.IsSupportedMRT()
	Message("MRT is not supported on this platform.")
	end
endif

// Define size for window and renders.
#constant WIDTH 1024
#constant HEIGHT 768

// Setup the window.
SetWindowTitle("MRT Example")
SetWindowSize(WIDTH, HEIGHT, 0)
SetVirtualResolution(WIDTH, HEIGHT)

// Create two render images, one for colour and the other for light.
colourImage = CreateRenderImage(WIDTH, HEIGHT, 0, 0)
lightImage = CreateRenderImage(WIDTH, HEIGHT, 0, 0)

// Create a sprite for the picture and another for the lamp.
pictureSprite = LoadSprite("fuji_from_misaka_pass.jpg")
lampSprite = LoadSprite("lamp.png")

// Create a screen quad to use for the final render and give it the two render images.
fullscreenQuad = CreateObjectQuad()
SetObjectImage(fullscreenQuad, colourImage, 0)
SetObjectImage(fullscreenQuad, lightImage, 1)

// Load and setup the shaders.
mrtShader = LoadSpriteShader("mrt_shader.glsl")
SetSpriteShader(pictureSprite, mrtShader)
SetSpriteShader(lampSprite, mrtShader)

lightingShader = LoadFullScreenShader("lighting_shader.glsl")
SetObjectShader(fullscreenQuad, lightingShader)

// Use the sprite colour red channel for the light level of the sprite.
SetSpriteColorRed(pictureSprite, 0)
SetSpriteColorRed(lampSprite, 255)

// Setup the images as multiple render targets.
MRT.SetRenderImage(0, colourImage)
MRT.SetRenderImage(1, lightImage)

// Position the picture in the centre of the screen.
SetSpritePositionByOffset(pictureSprite, WIDTH / 2, HEIGHT / 2)

do
	// Move the lamp with the pointer.
	SetSpritePositionByOffset(lampSprite, GetPointerX(), GetPointerY())
	
	// Update the game for this frame.
	Update(GetFrameTime())
	
	// Render our sprites into the render images.
	MRT.SetRenderToMRT()
	ClearScreen()
	Render()
	
	// Merge the images together by drawing the fullscreen quad to the screen.
	SetRenderToScreen()
	ClearScreen()
	DrawObject(fullscreenQuad)
	
	// Swap buffers to display the new frame.
    Swap()
loop
