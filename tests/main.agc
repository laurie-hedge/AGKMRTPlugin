#import_plugin MRT

#include "tests.agc"

#constant MARGINS 10.0

type ResultType
	resultMessage as String
	pass as Integer
endtype

global results as ResultType[]

// Stop on any AGK error.
SetErrorMode(2)

// Setup window.
SetWindowTitle("MRT Unit Tests")
SetWindowSize(1024, 768, 0)
SetVirtualResolution(1024, 768)
UseNewDefaultFonts(1)

// Check that the platform actually has MRT support.
if MRT.IsSupportedMRT()
	// Make sure errors fail silently, as some tests expect errors and these should not interrupt the app.
	MRT.SetErrorMode(0)
	
	// Run tests.
	TestGetMaxRenderImages()
	TestClearScreenWithMRT()
	TestUnattachingRenderImage()
	TestClearRenderImages()
	TestSwappingRenderImagesBeforeRender()
	TestSwappingRenderImagesAfterRender()
	TestInvalidAttachPointFails()
	TestAttachingNonSequentially()
	TestTransitionToSetRenderToImage()
	TestTransitionToSetRenderToScreen()
	TestUsingNonExistantImageFails()
	TestUsingDeletedImageFails()
	TestUsingMismatchedImageSizesFails()
	Test2DRendering()
	Test3DRendering()
	
	// Display results.
	SetupResults()
else
	// Display error.
	SetClearColor(255, 255, 255)
	errorText = CreateText("MRT is not supported on this platform. No tests run.")
	SetTextSize(errorText, 16)
	SetTextColor(errorText, 0, 0, 0, 255)
	SetTextPosition(errorText, MARGINS, 0.0)
endif

do
    Sync()
loop

function StartTest(testName as String)
	result as ResultType
	result.resultMessage = "Testing " + testName + "...  "
	result.pass = 0
	results.insert(result)
endfunction

function EndTest(pass as Integer)
	results[results.length].pass = pass
	if pass
		results[results.length].resultMessage = results[results.length].resultMessage + "Pass."
	else
		results[results.length].resultMessage = results[results.length].resultMessage + "Fail."
	endif
	MRT.ClearRenderImages()
	SetRenderToScreen()
endfunction

function SetupResults()
	SetClearColor(255, 255, 255)
	SetRenderToScreen()

	nextY# = 0.0
	passing = 0
	failing = 0
	for i = 0 to results.length
		resultText = CreateText(results[i].resultMessage)
		SetTextSize(resultText, 16)
		SetTextPosition(resultText, MARGINS, nextY#)
		if results[i].pass
			SetTextColor(resultText, 0, 0, 0, 255)
			passing = passing + 1
		else
			SetTextColor(resultText, 255, 0, 0, 255)
			failing = failing + 1
		endif
		nextY# = nextY# + GetTextTotalHeight(resultText)
	next i
	resultText = CreateText("------------------------------" + Chr(10) + "Passing: " + Str(passing) + Chr(10) + "Failing: " + Str(failing))
	SetTextSize(resultText, 16)
	SetTextPosition(resultText, MARGINS, nextY#)
	SetTextColor(resultText, 0, 0, 0, 255)
	nextY# = nextY# + GetTextTotalHeight(resultText)
	if failing = 0
		resultText = CreateText("*** TESTS PASSED ***")
		SetTextColor(resultText, 0, 0, 0, 255)
	else
		resultText = CreateText("*** TESTS FAILED ***")
		SetTextColor(resultText, 255, 0, 0, 255)
	endif
	SetTextSize(resultText, 16)
	SetTextPosition(resultText, MARGINS, nextY#)
endfunction

function ImageMatchesColour(img, red, green, blue)
	mem = CreateMemblockFromImage(img)
	width = GetMemblockInt(mem, 0)
	height = GetMemblockInt(mem, 4)
	pixelOffset = 12
	bufferEnd = 12 + (width * height * 4)
	while pixelOffset < bufferEnd
		if GetMemblockByte(mem, pixelOffset) <> red or GetMemblockByte(mem, pixelOffset + 1) <> green or GetMemblockByte(mem, pixelOffset + 2) <> blue
			DeleteMemblock(mem)
			exitfunction 0
		endif
		pixelOffset = pixelOffset + 4
	endwhile
	DeleteMemblock(mem)
endfunction 1

function ImagesMatch(img0, img1)
	mem0 = CreateMemblockFromImage(img0)
	mem1 = CreateMemblockFromImage(img1)
	width = GetMemblockInt(mem0, 0)
	height = GetMemblockInt(mem0, 4)
	if width <> GetMemblockInt(mem1, 0) or height <> GetMemblockInt(mem1, 0)
		DeleteMemblock(mem0)
		DeleteMemblock(mem1)
		exitfunction 0
	endif
	
	pixelOffset = 12
	bufferEnd = 12 + (width * height * 4)
	while pixelOffset < bufferEnd
		if GetMemblockByte(mem0, pixelOffset) <> GetMemblockByte(mem1, pixelOffset) or GetMemblockByte(mem0, pixelOffset + 1) <> GetMemblockByte(mem1, pixelOffset + 1) or GetMemblockByte(mem0, pixelOffset + 2) <> GetMemblockByte(mem1, pixelOffset + 2) or GetMemblockByte(mem0, pixelOffset + 3) <> GetMemblockByte(mem1, pixelOffset + 3)
			DeleteMemblock(mem0)
			DeleteMemblock(mem1)
			exitfunction 0
		endif
		pixelOffset = pixelOffset + 4
	endwhile
	
	DeleteMemblock(mem0)
	DeleteMemblock(mem1)
endfunction 1
