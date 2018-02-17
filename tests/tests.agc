function TestGetMaxRenderImages()
	StartTest("GetMaxRenderImages")
	maxRenderTargets = MRT.GetMaxRenderImages()
	EndTest(maxRenderTargets > 1)
endfunction

function TestClearScreenWithMRT()
	StartTest("ClearScreen works with MRT")
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 255, 0, 0) and ImageMatchesColour(img1, 255, 0, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestUnattachingRenderImage()
	StartTest("unattaching render images")
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	SetClearColor(0, 255, 0)
	
	MRT.SetRenderImage(0, 0)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 255, 0, 0) and ImageMatchesColour(img1, 0, 255, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestClearRenderImages()
	StartTest("unattaching render images")
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	SetClearColor(0, 255, 0)
	
	MRT.ClearRenderImages()
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 255, 0, 0) and ImageMatchesColour(img1, 0, 255, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestSwappingRenderImagesBeforeRender()
	StartTest("swapping render images before a render")
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(0, 0, 0)
	SetRenderToImage(img0, 0)
	ClearScreen()
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(1, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 0, 0, 0) and ImageMatchesColour(img1, 255, 0, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestSwappingRenderImagesAfterRender()
	StartTest("swapping render images after a render")
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	SetClearColor(0, 255, 0)
	
	MRT.SetRenderImage(0, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 255, 0, 0) and ImageMatchesColour(img1, 0, 255, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestInvalidAttachPointFails()
	StartTest("invalid attach point fails")
	
	img = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(0, 0, 0)
	SetRenderToImage(img, 0)
	ClearScreen()
	SetRenderToScreen()
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(MRT.GetMaxRenderImages(), img)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img, 0, 0, 0))
	
	DeleteImage(img)
endfunction

function TestAttachingNonSequentially()
	StartTest("attaching to higher attach points without lower ones")
	
	img = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(1, img)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img, 255, 0, 0))
	
	DeleteImage(img)
endfunction

function TestTransitionToSetRenderToImage()
	StartTest("transitioning to SetRenderToImage after using MRTs")
	
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	SetClearColor(0, 255, 0)
	
	SetRenderToImage(img1, 0)
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 255, 0, 0))
	
	DeleteImage(img0)
	DeleteImage(img1)
endfunction

function TestTransitionToSetRenderToScreen()
	StartTest("transitioning to SetRenderToScreen after using MRTs")
	
	img = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	SetClearColor(0, 255, 0)
	
	SetRenderToScreen()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img, 255, 0, 0))
	
	DeleteImage(img)
endfunction

function TestUsingNonExistantImageFails()
	StartTest("using a non-existant image as a render image fails")
	
	img = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(0, 0, 0)
	SetRenderToImage(img, 0)
	ClearScreen()
	SetRenderToScreen()
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img)
	MRT.SetRenderImage(1, 100)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img, 0, 0, 0))
	
	DeleteImage(img)
endfunction

function TestUsingDeletedImageFails()
	StartTest("using a deleted image as a render image fails")
	
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(8, 8, 0, 0)
	
	SetClearColor(0, 0, 0)
	SetRenderToImage(img1, 0)
	ClearScreen()
	SetRenderToScreen()
	
	SetClearColor(255, 0, 0)
	
	DeleteImage(img0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img1, 0, 0, 0))
	
	DeleteImage(img1)
endfunction

function TestUsingMismatchedImageSizesFails()
	StartTest("using render images with different sizes fails")
	
	img0 = CreateRenderImage(8, 8, 0, 0)
	img1 = CreateRenderImage(16, 16, 0, 0)
	
	SetClearColor(0, 0, 0)
	SetRenderToImage(img0, 0)
	ClearScreen()
	SetRenderToScreen()
	
	SetClearColor(255, 0, 0)
	
	MRT.SetRenderImage(0, img0)
	MRT.SetRenderImage(1, img1)
	MRT.SetRenderToMRT()
	
	ClearScreen()
	
	EndTest(ImageMatchesColour(img0, 0, 0, 0))
	
	DeleteImage(img1)
endfunction

function Test2DRendering()
	StartTest("2D rendering")
	
	img0 = CreateRenderImage(256, 256, 0, 0)
	img1 = CreateRenderImage(256, 256, 0, 0)
	img2 = CreateRenderImage(256, 256, 0, 0)
	
	mrtShader = LoadSpriteShader("mrt_sprite_frag.glsl")
	chessboard = LoadImage("chessboard.png")
	SetImageMinFilter(chessboard, 0)
	SetImageMagFilter(chessboard, 0)
	spr0 = CreateSprite(chessboard)
	spr1 = CreateSprite(chessboard)
	spr2 = CreateSprite(chessboard)
	SetSpriteSize(spr0, 512, 256)
	SetSpriteSize(spr1, 256, 512)
	SetSpriteSize(spr2, 128, 128)
	SetSpriteAngle(spr2, 45)
	SetSpriteOffset(spr1, GetSpriteWidth(spr1), GetSpriteHeight(spr1))
	SetSpritePositionByOffset(spr1, GetVirtualWidth(), GetVirtualHeight())
	SetSpritePositionByOffset(spr2, GetVirtualWidth() / 2, GetVirtualHeight() / 2)
	SetSpriteShader(spr0, mrtShader)
	SetSpriteShader(spr1, mrtShader)
	SetSpriteShader(spr2, mrtShader)
	SetClearColor(0, 0, 255)
	
	SetRenderToImage(img0, 0)
	ClearScreen()
	Render()
	
	MRT.SetRenderImage(0, img1)
	MRT.SetRenderImage(1, img2)
	MRT.SetRenderToMRT()
	ClearScreen()
	Render()
	
	EndTest(ImagesMatch(img0, img1) and ImagesMatch(img0, img2))
	
	DeleteImage(img0)
	DeleteImage(img1)
	DeleteImage(img2)
	DeleteSprite(spr0)
	DeleteSprite(spr1)
	DeleteSprite(spr2)
	DeleteImage(chessboard)
	DeleteShader(mrtShader)
endfunction

function Test3DRendering()
	StartTest("3D rendering")
	
	img0 = CreateRenderImage(256, 256, 0, 0)
	img1 = CreateRenderImage(256, 256, 0, 0)
	img2 = CreateRenderImage(256, 256, 0, 0)
	
	mrtShader = LoadShader("default_vert.glsl", "mrt_frag.glsl")
	chessboard = LoadImage("chessboard.png")
	SetImageMinFilter(chessboard, 0)
	SetImageMagFilter(chessboard, 0)
	obj0 = CreateObjectBox(20, 20, 20)
	obj1 = CreateObjectCapsule(15, 40, 0)
	obj2 = CreateObjectCone(20, 15, 32)
	SetObjectImage(obj0, chessboard, 0)
	SetObjectImage(obj1, chessboard, 0)
	SetObjectImage(obj2, chessboard, 0)
	SetObjectPosition(obj1, 0, 30, 5)
	SetObjectPosition(obj2, 30, 0, -30)
	SetObjectShader(obj0, mrtShader)
	SetObjectShader(obj1, mrtShader)
	SetObjectShader(obj2, mrtShader)
	SetCameraPosition(1, -50, 50, -50)
	SetCameraLookAt(1, 0, 0, 0, 0)
	SetClearColor(0, 0, 255)
	
	SetRenderToImage(img0, 0)
	ClearScreen()
	Render()
	
	MRT.SetRenderImage(0, img1)
	MRT.SetRenderImage(1, img2)
	MRT.SetRenderToMRT()
	ClearScreen()
	Render()
	
	EndTest(ImagesMatch(img0, img1) and ImagesMatch(img0, img2))
	
	DeleteImage(img0)
	DeleteImage(img1)
	DeleteImage(img2)
	DeleteObject(obj0)
	DeleteObject(obj1)
	DeleteObject(obj2)
	DeleteImage(chessboard)
	DeleteShader(mrtShader)
endfunction
