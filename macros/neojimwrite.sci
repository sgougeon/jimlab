//Copyright (C) 2017 - ENSIM, Université du Maine - Nicolas Aegerter
 //This file must be used under the terms of the CeCILL.
 //This source file is licensed as described in the file COPYING, which
 //you should have received as part of this distribution.  The terms
 //are also available at    
 //http://www.cecill.info/licences/Licence_CeCILL_V2.1-fr.txt

function jimwrite(jimage,imageMat,imagePath,Format,Name,Encoding)
 //javaclasspath('/usr/share/scilab//modules/jvm/jar/org.scilab.modules.jvm.jar');
    if(isdef(["imageMat"]))
        Mat = imageMat;
        arg_jimage = 0;
    elseif(isdef(["jimage"]))
        arg_jimage = 1;
        Mat = jimage.image;
    else
        arg_jimage = 0;
        error('Not any jimage or matrix argument have been definded')
    end
    disp(arg_jimage);
    
     
     if((ndims(Mat) ~= 4)&(ndims(Mat) ~= 3)&(ndims(Mat) ~= 2)) // Verify if Mat is a 2D,3D or 4D matrix 
            error('Argument Mat is not a matrix')
     end
    
    
    if(~isdef(["imagePath"]) | type(imagePath) ~= 10) //Verify if imagePath is a string  
        warning('Invalid Path of file, current depository will be used');
        imagePath = pwd;
    end
    
    if(isdef(["Format"]))
         invalid_Format = 0;
         defFormat = ['jpg','png','gif','bmp','wbmp'];
         compFormat = strstr(defFormat,Format); // Verify if user's specified format is supported
           if((type(Format) ~= 10)|(compFormat == '')) // If Format is not definded or wrong, 
                invalid_Format = 1;
           end
      elseif(~(isdef(["Format"]))) 
          
          invalid_Format = 1;
      end
      
      if(arg_jimage & invalid_Format) // Jimage format is used 
          Format = part(jimage.format,[2:length(jimage.format)])
           warning('Invalid format detected, Jimage format will be used :'..
          + Format)
     elseif(invalid_Format)
          Format = 'jpg';
          warning('Undefineded format, jpg will be used')
     end
     
     if(isdef(["Name"]))
         
         if((type(Name) ~= 10)|(Name == ''))// If Name isn't definded or wrong, the default value is 'No Name'
            warning('Name is not a string, the image will be called No_name');
            Name = 'No_name';
        end
     elseif(arg_jimage) 
         
         Name = jimage.title;
         warning('Invalid Name detected, Jimage''s name will be used :'..
          + Name)
     else
         Name = 'No_name';
         warning('Undefineded name, No_name will be used')     
    end
    
   if(isdef(["Encoding"]))
         invalid_Encoding = 0;
         defEncoding = ['rgb','rgba','gray'];
         compFormat = strstr(defEncoding,Encoding); // Verify if user's specified encoding is supported
         if((type(Encoding) ~= 10)|(compFormat == '')) // If Format is not definded or wrong, 
                invalid_Encoding = 1;
         end
    elseif(~(isdef(["Encoding"])))
        invalid_Encoding = 1;
     end
    if(arg_jimage & invalid_Encoding)// Jimage format is used 
        Encoding = jimage.encoding;
        warning('Invalid encoding detected, jimage encoding will be used : '..
         + jimage.encoding)
    elseif(invalid_Encoding)
          Encoding = 'rgb';//the default value is 'rgb'
        warning('Not any encoding have been definded. rgb will be used')
         warning('Transparency wont be efficient')
     end
     
     if(Encoding == 'rgba')
         if((Format == 'jpg')|(Format == 'bmp'))
             warning(Encoding +' is not aviable for '+ Format ..
             + ' type. png will be used')
             Format = 'png';
         end
     end
     
            
    jimport java.io.File;// Importe the java classes
    jimport javax.imageio.ImageIO; 
    jimport java.awt.image.BufferedImage;
    jimport java.awt.Color;   
 
    
     
    imagePath = imagePath + "/" + Name + "." + Format; // This code create the final path used by Java methode 'write'
   

    f = jnewInstance(File,imagePath);// Transfome Scilab object into Java object
    
    Form = jnewInstance("java.lang.String", Format);

    S = 0;
    
    select Encoding,
        case 'gray' then
            S =  jimwritegray(Mat,f,Form);
        case 'rgb' then
            S = jimwriteRGB(Mat,f,Form);
        case 'rgba' then
            S =  jimwriteRGBA(Mat,f,Form);

    else 
        error('Unexpected image type');
   end
    if  (~S)
        error('The image haven''t been saved');
    end
endfunction

    function Sa = jimwriteRGB(Mat,f,Form)
// This sub-function saved an image definded by a 3D rgb matrix using java methode "write", from BufferedImage class. 
// It is called by the function jimwrite.
// Mat : The wxhx3 3D matrix, f : a java object corresponding to imagePath,
// width : the width of the matrix, height : the height of the matrix.
           
         width = size(Mat,2);// Definition of image's size
        height = size(Mat,1);
        im = jnewInstance(BufferedImage,width,height, BufferedImage.TYPE_INT_RGB );
        tic
       jcompile("Ima",["public class Ima{"
       "public static int CstrImage(int width, int height, int[][][] Mat, int image){"
       "int l = 0;"
       "int c= 0;"
       "int im;"
       " for (l = 1; l <= height; l++){"
            "for(c =1; c<= width; c++){"
               "int A = java.awt.Color.Color( Mat[l][c][1],Mat[l][c][2],Mat[l][c][3],1);"
               
               "im = setRGB((c-1),(l-1),getRGB(A));"
                "}"
         "}"
         "return im;"
        "}}"]);
        im = Ima.CstrImage(width,height,Mat,im);
         toc
disp('RGB')
        Sa = ImageIO.write(im, Form, f);



        jremove f im A Form R;

    endfunction

    function Sa = jimwriteRGBA(Mat,f,Form)
// This sub-function saved an image definded by a 4D rgba matrix using java methode "write", from BufferedImage class. 
// It is called by the function jimwrite.
// Mat : The wxhx4 4D matrix, f : a java object corresponding to imagePath,
// width : the width of the matrix, height : the height of the matrix.

       
         width = size(Mat,2);  // Definition of image's size
        height = size(Mat,1);
        im = jnewInstance(BufferedImage,width,height, BufferedImage.TYPE_INT_ARGB );
        if(ndims(Mat) == 3)
            for (l = 1:height)
                for(c =1:width) 
                    A = jnewInstance(Color, double(Mat(l,c,1)),..
                    double(Mat(l,c,2)),double(Mat(l,c,3)),255);
                    R = jinvoke(A,"getRGB");
                    jinvoke(im,"setRGB", int(c-1), int(l-1), int(R));
                end
            end
        else
            for (x = 1:height)
                for(y =1:width) 
    
                    A = jnewInstance(Color, double(Mat(x,y,1)),.. 
                    double(Mat(x,y,2)), double(Mat(x,y,3)),..
                    double(Mat(x,y,4)));
                    R = jinvoke(A,"getRGB");
                    jinvoke(im,"setRGB", int(y-1), int(x-1), int(R));
                   end
            end
        end
        
disp('RGBA')
        Sa = ImageIO.write(im, Form, f);

        jremove f im A Form R; 
    
    endfunction

    function Sa = jimwritegray(Mat,f,Form)
// This sub-function saved an image in gray scale definded by a 2D matrix using java methode "write", from BufferedImage class. 
// It is called by the function jimwrite.
// Mat : The wxh 2D matrix, f : a java object corresponding to imagePath,
// width : the width of the matrix, height : the height of the matrix.

      
         width = size(Mat,2);  // Definition of image's size
         height = size(Mat,1);
         im = jnewInstance(BufferedImage,width,height, BufferedImage.TYPE_BYTE_GRAY );
        for (x = 1:width)
            for(y =1:height) 
            A = jnewInstance(Color, double(Mat(x,y)),128,128,128);
            R = jinvoke(A,"getRGB");
            jinvoke(im,"setRGB", int(y-1), int(x-1), int(R));
           end
        end
disp('gray')
        Sa = ImageIO.write(im, Form, f);

         jremove f im A Form R;
    
    endfunction

    

    
