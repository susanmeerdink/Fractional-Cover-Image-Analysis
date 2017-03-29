function varargout = gui_image_analysis(varargin)
% GUI_IMAGE_ANALYSIS MATLAB code for gui_image_analysis.fig
%      GUI_IMAGE_ANALYSIS, by itself, creates a new GUI_IMAGE_ANALYSIS or raises the existing
%      singleton*.
%
%      H = GUI_IMAGE_ANALYSIS returns the handle to a new GUI_IMAGE_ANALYSIS or the handle to
%      the existing singleton*.
%
%      GUI_IMAGE_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_IMAGE_ANALYSIS.M with the given input arguments.
%
%      GUI_IMAGE_ANALYSIS('Property','Value',...) creates a new GUI_IMAGE_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_image_analysis_OpeningFcn gets called.  An
%      unrecognized property name or inva                         lid value makes property application
%      stop.  All inputs are passed to gui_image_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_image_analysis

% Last Modified by GUIDE v2.5 12-Jul-2016 10:55:18
% Modified by Susan Meerdink

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_image_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_image_analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_image_analysis is made visible.
function gui_image_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_image_analysis (see VARARGIN)

% Choose default command line output for gui_image_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes gui_image_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_image_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_pushbutton.
function load_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this function loads in the files for image analysis

evalin('base','load tree') %Load in the classification tree for future steps
evalin('base','load treeUpdated') %Load in the classification tree for future steps
[fnames,folder] = uigetfile('C:\IDEAS\Digital Images\*.JPG','Select Files to Load','MultiSelect','on');
try %If fileInfo exists (only happens if you are loading in files a second time)
    fileInfo = evalin('base','fileInfo');
catch %If fileInfo doesn't exist
    fileInfo = [];
end 

%Loop through and open files
if iscell(fnames) == 0  %If no or one file are selected, fnames is returned as a string NOT cell
    if fnames == 0 %If no files are selected
        errordlg('No Files Selected','Error');
    else %if one file is selected
        %Setting up variables for workspace and future analysis
        varname = fnames;%get filename to prepare for matlab variable
        varname = char(strtok(varname,'.'));% remove file extension
        filename  = varname; %Save the original file name
        varname = strcat('var_',varname);%add var_ to variable name in case it starts with numbers
        assignin('base',varname,importdata([folder,char(fnames)])); %assigning to workspace
        fileInfo{size(fileInfo,1)+1,1} = varname;
        fileInfo{size(fileInfo,1),2} = filename;
        fileInfo{size(fileInfo,1),3} = folder;
        fileInfo{size(fileInfo,1),4} = 'Orig';
        
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames),'.');
        crop_name = strcat(splitname(1),'_crop');
        crop_folder = strcat(folder,'Crop\');
        crop_path = strcat(crop_folder,crop_name,'.',splitname(2));
        if exist(char(crop_path),'file')
            input =[crop_folder,char(crop_name),'.',char(splitname(2))]; 
            var_crop_name = strcat('var_',crop_name); 
            assignin('base',char(var_crop_name),importdata(input)) ;
            fileInfo{size(fileInfo,1)+1,1} = var_crop_name;
            fileInfo{size(fileInfo,1),2} = crop_name;
            fileInfo{size(fileInfo,1),3} = crop_folder;
            fileInfo{size(fileInfo,1),4} = 'Crop';
        end

        %Check to see if classified files exist
        class_name = strcat(splitname(1),'_class');
        class_folder = strcat(folder,'Classification\');
        class_path = strcat(class_folder,class_name,'.',splitname(2));
        var_class_name = strcat('var_',class_name);
        if exist(char(class_path),'file')
            input =[class_folder,char(class_name),'.',char(splitname(2))];
            assignin('base',char(var_class_name),importdata(input));
            fileInfo{size(fileInfo,1)+1,1} = var_class_name;
            fileInfo{size(fileInfo,1),2} = class_name;
            fileInfo{size(fileInfo,1),3} = class_folder;
            fileInfo{size(fileInfo,1),4} = 'Class';
        end
        
        %Assign final variables to workspace & update GUI
        assignin('base','fileInfo',fileInfo);
        update_table(handles)
    end   
else %if multiple files are selected
    fileInfo = [];
    for n = 1:size(fnames,2) %Loop through files   
        %Setting up variables for workspace and future analysis
        varname = fnames(n); %get file name to prepare for variable names
        varname = char(strtok(varname,'.')); %remove file extension
        filename = varname; %set the original file name
        varname = strcat('var_',varname); %add 'var_' onto front in case the file starts with numbers (which isn't a valid matlab variable name
        assignin('base',char(varname),importdata([folder,char(fnames(n))]));
        fileInfo{size(fileInfo,1)+1,1} = varname;
        fileInfo{size(fileInfo,1),2} = filename;
        fileInfo{size(fileInfo,1),3} = folder;
        fileInfo{size(fileInfo,1),4} = 'Orig';
        
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames(n)),'.');
        crop_name = strcat(splitname(1),'_crop');
        crop_folder = strcat(folder,'Crop\');
        crop_path = strcat(crop_folder,crop_name,'.',splitname(2));
        if exist(char(crop_path),'file')
            input = [crop_folder,char(crop_name),'.',char(splitname(2))]; 
            var_crop_name = strcat('var_',crop_name);
            assignin('base',char(var_crop_name),importdata(input)) ;
            fileInfo{size(fileInfo,1)+1,1} = var_crop_name;
            fileInfo{size(fileInfo,1),2} = crop_name;
            fileInfo{size(fileInfo,1),3} = crop_folder;
            fileInfo{size(fileInfo,1),4} = 'Crop';
        end
        
        %Check to see if classified files exist
        class_name = strcat(splitname(1),'_class');
        class_folder = strcat(folder,'Classification\');
        class_path = strcat(class_folder,class_name,'.',splitname(2));
        if exist(char(class_path),'file')
            input = [class_folder,char(class_name),'.',char(splitname(2))];
            var_class_name = strcat('var_',class_name);
            assignin('base',char(var_class_name),importdata(input));
            fileInfo{size(fileInfo,1)+1,1} = var_class_name;
            fileInfo{size(fileInfo,1),2} = class_name;
            fileInfo{size(fileInfo,1),3} = class_folder;
            fileInfo{size(fileInfo,1),4} = 'Class';
        end
        
    end
    %Assign final variables to workspace & update GUI
    assignin('base','fileInfo',fileInfo); 
    update_table(handles)
end

function update_table(handles)
%Updating GUI table, this is called anything loading, cropping, or
%classification is completed.

%Update Table with new variables
allVars = evalin('base','who');
fileInfo = evalin('base','fileInfo');
total = 0; %total number of things to display
index = []; %indices to display
for i = 1:size(fileInfo,1) %get the number of files
    if strcmp(fileInfo{i,4},'Orig')== 1
        total = total + 1;
        index = [index i];
    end
end
x = cell(total,3);

for m = 1:total %Find the original file names in the workspace variables
    indiv = index(m);
    for n = 1: length(allVars)
        if strcmp(fileInfo{indiv,1},allVars(n)) == 1
            x{m,1} = strrep(allVars{n},'var_','');
            break
        end
    end
end

%Check if the photos have been cropped, update table status
for j = 1: size(x,1)
    test = strcmp(strcat('var_',x{j},'_crop'),allVars);
    for t = 1: size(test,1)
        if test(t) == 1
            x{j,2} = 'yes';
            break
        else
            continue
        end
    end
    if isempty(x{j,2}) == 1
        x{j,2} = 'no';
    end
end

%Check if the photos have been classified, update table status
for k = 1: size(x,1)
    test = strcmp(strcat('var_',x{k},'_class'),allVars);
    for t = 1:size(test,1)
        if test(t) == 1
            x{k,3} = 'yes';
            break
        else
            continue
        end
    end
    if isempty(x{k,3}) == 1
        x{k,3} = 'no';
    end
end

assignin('base','x',x); %Assign variable to workspace
set(handles.uitable1,'Data',x) %Update table in GUI

% --- Executes on button press in cropbutton.
function cropbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cropbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This function loops through and crops images based on user input

%Grab variables from workspace
x = evalin('base','x');
fileInfo = evalin('base','fileInfo');

for i = 1: size(x,1) %Loop through files
    if strcmp(x{i,2},'no') == 1
        %Find the original file information
        for n = 1:size(fileInfo,1)
            if strcmp(strcat('var_',x{i,1}),fileInfo{n,1}) == 1
                index = n;
            end
        end
        
        %Display original image
        I = char(strcat(fileInfo{index,3},fileInfo{index,2},'.jpg')); %Grab file name
        figure('units','normalized','outerposition',[0 0 0.5 0.5])
        imshow(I)
        descr1 = {'1. Drag Rectangle Outline for Crop   2. Right click  3. Select Crop Image 4. The cropped image will appear when done.';};
        descr2 = {'Goal: Drag rectangle to cover as much area as possible within white square (do not include white square!)'};
        title([fileInfo{index,1}],'Interpreter','none')
        text(0, -0.02, descr1,'Units','normalized','FontSize',12)
        text(0, -0.05, descr2,'Units','normalized','FontSize',12)
        
        %User drags crop outline
        [Icrop,~] = imcrop; %Crop image
        if isempty(Icrop) == 0  %If the user selected an area to crop
            figure('units','normalized','outerposition',[0.5 0 0.5 0.5])
            imshow(Icrop); %Display Image
            title([fileInfo{index,1},'_crop',],'Interpreter','none')
            assignin('base',[fileInfo{index,1},'_crop'],Icrop); %Assign value to variable in specified workspace
            fileInfo{(size(fileInfo,1)+1),1} = strcat(fileInfo{index,1},'_crop');
            fileInfo{(size(fileInfo,1)),2} = strcat(fileInfo{index,2},'_crop');
            fileInfo{(size(fileInfo,1)),3} = strcat(fileInfo{index,3},'\Crop\');
            fileInfo{(size(fileInfo,1)),4} = 'Crop';
            assignin('base','fileInfo',fileInfo)
            
            %SAVE CROPPED FILE TO CROP FOLDER
            cflder = strcat(fileInfo{index,3},'\Crop\');
            if isdir(cflder)== 0 %If the directory doesn't exist make it
                mkdir(cflder)
            end
            fname = strcat(fileInfo{index,3},'\Crop\',fileInfo{index,2},'_crop.jpg');
            imwrite(Icrop,fname)
            x{i,2} = 'yes';
            assignin('base','x',x);
         
            % Construct a questdlg with three options
            choice = questdlg('Crop next image?', 'Continue?', 'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    close Figure 1
                    close Figure 2
                    continue
                case 'No'
                    close Figure 1
                    close Figure 2
                    break
            end
        else %If user didn't select an area to crop, don't do anything
            break
        end
    end   
end
update_table(handles)

% --- Executes on button press in classify_pushbutton.
function classify_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to classify_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this function classifies the image into fractional components: NPV, GV,
% Shade, Blue flowers, Yellow Flowers.

%Grab variables from workspace
x = evalin('base','x');
fileInfo = evalin('base','fileInfo');
count = 1;
fractions = [];
t0 = evalin('base','t0');
tree = evalin('base','tree');
versionTest = version('-release');

for i = 1: size(x,1) %Loop through files
    if strcmp(x{i,3},'no') == 1 && strcmp(x{i,2},'yes') == 1 %If the file has been cropped, but not classified
        %Find the cropped file information
        for n = 1:size(fileInfo,1)
            if strcmp(strcat('var_',x{i,1},'_crop'),fileInfo{n,1}) == 1
                pos = n;
            end
        end
        
        %Grabbing workspace variables
        I = evalin('base',char(fileInfo{pos,1}));
        
        %Apply Tree
        for j = 1:3
            RowS = I(:,:,j);
            all_rgb(:,j) = double(RowS(:));
        end
        ratioGR = all_rgb(:,2)./all_rgb(:,1);
        sumRGB = sum(all_rgb,2);
        data = [all_rgb,ratioGR,sumRGB];
        
        if str2num(versionTest(1:4)) < 2016
            treeOut_x_0 = treeval(t0,data);
            %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead. 
        else
            treeOut_x_0 = predict(tree,data);
        end
                     
        R=all_rgb(:,1);
        G=all_rgb(:,2);
        B=all_rgb(:,3);
        treeOut_x_0(B > G + 40 & R > 160) = 4; %Blue Flowers
        treeOut_x_0(R./B > 1.8 & G./B > 1.8 & R + G > 400) = 5; %YELLOW FLOWERS
        fractions(count,:) = horzcat(size(fileInfo,1)+1,hist(treeOut_x_0,1:5)/length(sumRGB));
        %Column Organization: index of fileInfo, Percentages of NPV, Shade, GV, Blue Flowers, Yellow Flowers

        %Create Figure    
        szImg=size(RowS);
        m=szImg(1);
        n=szImg(2);
        yout = reshape(treeOut_x_0,m,n);
        
        %Updating Variable names
        new_name = char(strrep(fileInfo{pos,2},'_crop','_class'));
        var_name = char(strcat('var_',new_name));
        assignin('base',var_name,yout); %Assign value to variable in specified workspace
        
        %DISPLAY CLASSIFICATION RESULTS
        figure('units','normalized','outerposition',[0 0 1 0.75])
        subplot(1,3,1)%Original Image
        hold on
        title([fileInfo{pos,2},' Original'],'Interpreter','none')
        imagesc(I)
        axis square; axis off
        hold off
        
        subplot(1,3,2) %Classification
        hold on
        title([new_name, ' Classification'],'Interpreter','none')
        im = imagesc(yout);%Display image with scaled colors
        cmap = [1 1 1; 0 0 0; 0 1 0; 0 0 1; 1 1 0]; %colormap: white, black, green, [Blue, Yellow]
        set(gca,'CLim',[1 5])
        colormap(cmap)
        axis square; axis off
        hold on
        
        subplot(1,3,3) %ColorBar
        hold on
        ytlabel={[num2str(100*fractions(count,2),2),'% Non-Photosynthetic Vegetation'],...
            [num2str(100*fractions(count,3),2),'% Shade'],...
            [num2str(100*fractions(count,4),2),'% Green Vegetation'],...
            [num2str(100*fractions(count,5),2),'% Blue Flowers'],...
            [num2str(100*fractions(count,6),2),'% Yellow Flowers']};

        if str2num(versionTest(1:4)) > 2014
            %Only works for MATLAB 2015 or newer
            colorbar('Location','west',...
                'Ticks',[0.1, 0.3, 0.5, 0.7, 0.9],...
                'FontSize',14,...
                'TickLabels',ytlabel)
        else
            %For older versions of matlab (tested on 2013)
            colorbar('Location','west','YTick',[0.1:0.2:0.9])
            text(0.1,0.1, ytlabel(1),'FontSize',14)
            text(0.1,0.3, ytlabel(2),'FontSize',14)
            text(0.1,0.5, ytlabel(3),'FontSize',14)
            text(0.1,0.7, ytlabel(4),'FontSize',14)
            text(0.1,0.9, ytlabel(5),'FontSize',14)
        end 
        axis off
        hold off

        %Updating More Variables and assigning to workspace
        cflder = char(strrep(fileInfo{pos,3},'Crop\','Classification\'));
        fileInfo{(size(fileInfo,1)+1),1} = var_name;
        fileInfo{(size(fileInfo,1)),2} = new_name;
        fileInfo{(size(fileInfo,1)),3} = cflder;
        fileInfo{(size(fileInfo,1)),4} = 'Class';
        assignin('base','fileInfo',fileInfo)
        
        %SAVE CLASSIFICATION FILE TO CLASSIFICATION FOLDER
        if isdir(cflder)== 0 %If the directory doesn't exist make it
            mkdir(cflder)
        end
        fname = strcat(cflder,new_name,'.jpg');
        imwrite(yout,cmap,fname);
        
        %Updating, assigning variables
        x{i,3} = 'yes';
        assignin('base','x',x);
        count = count + 1;
        clear all_rgb
        assignin('base','fractions',fractions)
        
        % Construct a questdlg with three options
        choice = questdlg('Classify next image?', 'Continue?', 'Yes','No','No');
        % Handle response
        switch choice
            case 'Yes'
                close Figure 1
                continue
            case 'No'
                close Figure 1
                break
        end
    else
        continue
    end
end   
update_table(handles)

% --- Executes on button press in output_pushbutton.
function output_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to output_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This function takes the classification results executed in this session
% and saves them to a csv file
fileInfo = evalin('base','fileInfo');
fractions = evalin('base','fractions');
outputFile = strcat(fileInfo{1,3},'fractional_cover_stats_',datestr(now,'ddmmmyy'),'.csv');
[fileout,path] = uiputfile(outputFile,'Save file name');
fid = fopen([path,char(fileout)],'w');
fprintf(fid,'Filename,NPV,Shade,GV,Flower Blue, Flower Yellow,File Location\n');
for i = 1:size(fractions,1)
    fprintf(fid,'%s%s',char(fileInfo{fractions(i,1),2}),',');
    fprintf(fid,'%f ,%f,%f,%f,%f,',fractions(i,[2:6])); %Classification Values (5 vals, cell 5)
    fprintf(fid,'%s,\n',char(fileInfo{fractions(i,1),3})); %File Location for Classification Images
end
fclose(fid);
msgbox('Completed processing of classification results.','Done!')
