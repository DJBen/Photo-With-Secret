Photo-With-Secret
=================

An iOS app that can hide a text message inside a photo. The changes made to photo is so subtle that your eyes cannot distinguish the encrypted photo from the original one.

It also tries out the blur effect and interpolation effect on `UIVIew` supported on iOS 7.

Requirements
-----------------
iOS 7.

Usage
-----------------
Open with Xcode, run the app. 

Implementation Details
-----------------
First, it convert the message into [Brainfuck](http://en.wikipedia.org/wiki/Brainfuck) language using my handy [NSString+Brainfuck](https://github.com/DJBen/NSString-Brainfuck) category. This language only has 8 characters (+ - > < . , [ ]).

Next, it convert the image into bitmap (resize it first if necessary). For every pixel in bitmap, there are 4 channels (R, G, B, Alpha). It will choose some pixels to store your secret message represented in Brainfuck. Since there are only 8 characters in the converted message, they can be represented in binary (000, 001, 010, 011, 100, 101, 110, 111). I change the value of RGB channels of one pixel by 0 or 1 respectively, letting the values mod 2 of these three channels be the exact binary code (e.g. if I need to convert '>', its binary code may be 010, that pixel's R value mod 2 will be 0, G value mod 2 will be 1, B value mod 2 will be 0), so that a pixel can store a Brainfuck character without changing too much to be distinguishable from original pixel.

Note
-----------------
Do not resize the output image, or you will probably (>99%) lose your hidden message in it!
