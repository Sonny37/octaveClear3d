%chdir('C:\Users\vrouille\Desktop\mire2D8TE');
pkg load image
img_gray=imread('11502003-2016-05-17-182355.tif');
figure(1)
imshow(img_gray);
img_colorful=imread('Sans titre.png');
img_red = img_colorful ;
img_blue = img_colorful ;
img_green = img_colorful ;
img_red(:,:,[2,3])=0 ;
figure(2)% to see only one
% part out of three of the color aspect of a image  
imshow (img_red )
subplot(311)
imshow (img_red )
subplot(312)
img_green(:,:,[1,3])=0;
imshow (img_green)
img_blue(:,:,[1,2])=0;
subplot(313)
imshow (img_blue) 
%----------
% frequency_of_gray_img=fft2(img_gray); %fourier transform
% abs_freq_gray= abs(frequency_of_gray_img );
% figure(3); 
% imshow(abs_freq_gray); % img is blank
% abs_freq_gray =abs(fftshift (frequency_of_gray_img ));
% imshow(imadjust(abs_freq_gray)); % img is no blank  anymore
%---
a=impixel (img_gray, 1:columns(img_gray),1:rows(img_gray))./255