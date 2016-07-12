# Fractional-Cover-Image-Analysis

Project related to processes camera images into percent GV, NPV, Shade, Blue and Yellow Flowers.

### Background:
This code was written for the IDEAS (Innovative Datasets for Environmental Analysis by Students) project
run by Dr. Dar Roberts in the University of California Santa Barbara Geography Department.
See http://geog.ucsb.edu/ideas/ for more information
As part of this project, students lay transects at our various field sites to take measurements that
relate to environmental variables. One of these measurements is taking a photo with an RGB camera and 
using the resulting image to determine percent green vegetation, non-photosynthetic vegetation, shade,
blue and yellow flowers. This code is used to process this imagery and get percent composition.

### Dependencies/ Requirements:
This code was designed for a Nikon Coolpix 5700. It may work on other imagery, but needs to be tested.
Developed on MATLAB 2015 and MATLAB 2013. 

### Steps:
#### STARTING PROGRAM:
1. Open MATLAB and naviagate to folder with the Fractional-Cover-Image-Analysis source code. 
2. Open gui_image_analysis.m into the MATLAB editor.
3. In the editor tab, hit Run which will result in a GUI appearing.

#### LOADING IMAGES:
1. Click the "Load *.jpg File(s)" button. 
2. A dialog box will open where you can navigate to the location that contains the images you want to process. 3. Select the photo or photos that you want to load into the program. Once selected hit Open. 
4. The program will then load in the orignal photos and check to see if a cropped or classified image exists already. If they do exist the table will update to say yes.
*ONLY load original, full images NOT cropped or classified images. If you have already cropped images, the program will search and find those once you've uploaded the original images.
*Do not change filenames - the original, cropped, and classified images must have same beginning.

#### CROPPING IMAGES:
1. Click the "Crop" button to start going through your images to crop. 
2. The program will pop up a window showing you the original image. 
3. Click and drag over the image to select the area of interest. Generally speaking this is the area inside the white square in the picture. Avoid capturing the white square or any other objects that may have entered the field of view. 
4. Once the area of interest is selected, right click and choose "Crop Image".
5. The program will open a new figure with the cropped image.
6. The program will automatically save the cropped image. An additional folder will be added to the directory containing the original folders titled "Crop". The image will be saved into this new Crop folder with the originalname_crop.jpg. and will save the image.
7. A dialog window will appear saying "Do you want to continue cropping?". To move on to the next image, hit yes. If you are done cropping for now, hit no. 
*The program will always start with the first file that needs to be cropped and goes down the list.

#### CLASSIFYING IMAGES:
1. click "Classify" button to start going through your images to classify using a pre-defined decision tree.
*This decision tree was built for the Coal Oil Point Reserve site. Use caution if using in a different area.
2. The program will classify the first image that has been cropped but not classified. 
3. A figure will pop up with the cropped image, classified image, and a colorbar. The colorbar includes the percentages for each of the classes present in the image. 
4. The program will automatically save the classified image. An additional folder will be added to the directory containing the original folders titled "Classification". The image will be saved into this new Classification folder with the originalname_class.jpg.
5. A dialog window will appear saying "Do you want to continue cropping?". To move on to the next image, hit yes. If you are done classifying for now, hit no. 

#### OUTPUT CLASSIFICATION RESULTS:
1. Click "Output to *.csv" button to output this current sessions classification results. The program will not output results from images that were classified outside of the matlab session.
2. A dialog box will open allowing the user to choose the name and location of the output .csv file. 
3. The program will then save the classification results to the .csv file.
4. When the saving is complete a dialog box will appear saying "Completed processing of classification results."

### Known Warnings
These are warnings that MATLAB will throw as you run this program. They are known issues and will be fixed in future versions. They do not impact processing and should be ignored for the moment.

*	Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead. 
*	Warning: Image is too big to fit on screen; displaying at 33% 