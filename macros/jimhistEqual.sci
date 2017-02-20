 //Copyright (C) 2017 - ENSIM, Université du Maine - Camille CHAILLOUS
 //
 //This file must be used under the terms of the CeCILL.
 //This source file is licensed as described in the file COPYING, which
 //you should have received as part of this distribution.  The terms
 //are also available at    
 //http://www.cecill.info/licences/Licence_CeCILL_V2.1-fr.txt

 function [equalizedJimage] = jimhistEqual(jimage)
     if (typeof(jimage) == "jimage" | typeof(jimage) == "hypermat" | ..
                                        typeof(jimage) == "uint8") 
        jim = typeof(jimage) == "jimage"
        dim = size(jimage)
        N = dim(1)*dim(2)
        gray = length(dim) == 2
        
        //Case of a matrix with gray levels
        if gray & ~jim
            [newLevel, ind] = jimhistEqual_level(jimage);
            //each pixel is assiciated with its new level
            for i = 1:dim(1)
                for j = 1:dim(2)
                    equalizedJimage(i,j) = newLevel(ind(i,j))
                end
            end
            //convertion into 8-bits unsigned intergers
            equalizedJimage = uint8(equalizedJimage)
        end
        
        //case of an object jimage with type of encoding 'gray'
        if gray & jim
            [newLevel, ind] = jimhistEqual_level(jimage.image);
            //each pixel is assiciated with its new level
            for i = 1:dim(1)
                for j = 1:dim(2)
                    equalizedImage(i,j) = newLevel(ind(i,j))
                end
            end
            //convertion into 8-bits unsigned intergers
            equalizedImage = uint8(equalizedImage)
            equalizedJimage = mlist(['jimage','image','encoding','title',..
                'format'], equalizedImage,jimage.encoding , jimage.title, ..
                                                            jimage.format);
        end
        
        //Case of a hypermatrix with RGB levels
        if ~gray & ~jim
            [newLevel, ind] = jimhistEqual_level(jimage);
            //each pixel is assiciated with its new level
            for i = 1:dim(1)
                for j = 1:dim(2)
                    for k = 1:dim(3)
                        equalizedJimage(i,j,k) = newLevel(ind(i,j,k))
                    end
                end
            end
            //convertion into 8-bits unsigned intergers
            equalizedJimage = uint8(equalizedJimage)
        end
        
        //case of an object jimage with type of encoding 'rgb' or 'rgba'
        if ~gray jim
            [newLevel, ind] = jimhistEqual_level(jimage);
            //each pixel is assiciated with its new level
            for i = 1:dim(1)
                for j = 1:dim(2)
                    for k = 1:dim(3)
                        equalizedImage(i,j,k) = newLevel(ind(i,j,k))
                    end
                end
            end
            //convertion into 8-bits unsigned intergers
            equalizedImage = uint8(equalizedImage)
            equalizedJimage = mlist(['jimage','image','encoding','title',..
                'format'], equalizedImage,jimage.encoding , jimage.title, ..
                                                            jimage.format);
        end 
     else
        msg = _("%s: Argument #%d: M-list or encoded integer(s) of type (%s) ..
        or %s expected.\n");
        error(msprintf(msg,"jimhistEqual",1,"uint8","hypermet"));
     end
 endfunction

function [newLevel, ind] = jimhistEqual_level(im)
//This sub-function returns the new levels of an image after histogram equalisation and the indice of each pixel. It is used by the function jimhistEqual()
//newLevel : an array with the new levels
//ind : The indice of each pixel
//im : a 2D matrix with the level of each pixel of an image from 0 to 255

    x = [0:1:256]
    data = double(im)
    [cf, ind] = histc(x, data, normalization = %t)
    tmp = 0
    for i = 1:length(cf)
        tmp = tmp + cf(i)
        newLevel(i) = tmp*255
    end
    
endfunction
