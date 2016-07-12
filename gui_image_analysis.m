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
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_image_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_image_analysis

% Last Modified by GUIDE v2.5 11-Jul-2016 15:45:06

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
evalin('base','load tree')
[fnames,folder] = uigetfile('C:\IDEAS\Digital Images\*.JPG','Select Files to Load','MultiSelect','on');
try 
    fileInfo = evalin('base','fileInfo');
catch
    fileInfo = [];
end 

if iscell(fnames) == 0  %If no or one file are selected
    if fnames == 0 %If no files are selected
        errordlg('No Files Selected','Error');
    else %if one file is selected
        varname = fnames;
        varname = char(strtok(varname,'.'));
        assignin('base',varname,importdata([folder,char(fnames)]));
        fileInfo{size(fileInfo,1)+1,1} = varname;
        fileInfo{size(fileInfo,1),2} = folder;
        fileInfo{size(fileInfo,1),3} = 'Orig';
        
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames),'.');
        crop_name = strcat(splitname(1),'_crop');
        crop_folder = strcat(folder,'Crop\');
        crop_path = strcat(crop_folder,crop_name,'.',splitname(2));
        if exist(char(crop_path),'file')
            input =[crop_folder,char(crop_name),'.',char(splitname(2))]; 
            assignin('base',char(crop_name),importdata(input)) ;
            fileInfo{size(fileInfo,1)+1,1} = crop_name;
            fileInfo{size(fileInfo,1),2} = crop_folder;
            fileInfo{size(fileInfo,1),3} = 'Crop';
        end

        %Check to see if classified files exist
        class_name = strcat(splitname(1),'_class');
        class_folder = strcat(folder,'Classification\');
        class_path = strcat(class_folder,class_name,'.',splitname(2));
        if exist(char(class_path),'file')
            input =[crop_folder,char(class_name),'.',char(splitname(2))];
            assignin('base',char(class_name),importdata(input));
            fileInfo{size(fileInfo,1)+1,1} = class_name;
            fileInfo{size(fileInfo,1),2} = class_folder;
            fileInfo{size(fileInfo,1),3} = 'Class';
        end
        assignin('base','fileInfo',fileInfo);
        update_table(handles)
    end   
else %if multiple files are selected
    fileInfo = [];
    for n = 1:size(fnames,2) %Loop through files   
        varname = fnames(n);
        varname = char(strtok(varname,'.'));
        assignin('base',char(varname),importdata([folder,char(fnames(n))]));
        fileInfo{size(fileInfo,1)+1,1} = varname;
        fileInfo{size(fileInfo,1),2} = folder;
        fileInfo{size(fileInfo,1),3} = 'Orig';
        
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames(n)),'.');
        crop_name = strcat(splitname(1),'_crop');
        crop_folder = strcat(folder,'Crop\');
        crop_path = strcat(crop_folder,crop_name,'.',splitname(2));
        if exist(char(crop_path),'file')
            input =[crop_folder,char(crop_name),'.',char(splitname(2))]; 
            assignin('base',char(crop_name),importdata(input)) ;
            fileInfo{size(fileInfo,1)+1,1} = crop_name;
            fileInfo{size(fileInfo,1),2} = crop_folder;
            fileInfo{size(fileInfo,1),3} = 'Crop';
        end
        
        %Check to see if classified files exist
        class_name = strcat(splitname(1),'_class');
        class_folder = strcat(folder,'Classification\');
        class_path = strcat(class_folder,class_name,'.',splitname(2));
        if exist(char(class_path),'file')
            input =[crop_folder,char(class_name),'.',char(splitname(2))];
            assignin('base',char(class_name),importdata(input));
            fileInfo{size(fileInfo,1)+1,1} = class_name;
            fileInfo{size(fileInfo,1),2} = class_folder;
            fileInfo{size(fileInfo,1),3} = 'Class';
        end
        
    end
    assignin('base','fileInfo',fileInfo); 
    update_table(handles)
end

function update_table(handles)
%Updating GUI table

%Update Table with new variables
allVars = evalin('base','who');
fileInfo = evalin('base','fileInfo');
total = 0; %total number of things to display
index = []; %indices to display
for i = 1:size(fileInfo,1)
    if strcmp(fileInfo{i,3},'Orig')== 1
        total = total + 1;
        index = [index i];
    end
end
x = cell(total,3);

for m = 1:total %Only show photos in listbox
    indiv = index(m);
    for n = 1: length(allVars)
        if strcmp(fileInfo{indiv,1},allVars(n)) == 1
            x{m,1} = allVars{n};
            break
        end
    end
end

%Check if the photos have been cropped, update table status
for j = 1: size(x,1)
    test = strcmp(strcat(x{j},'_crop'),allVars);
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
    test = strcmp(strcat(x{j},'_class'),allVars);
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

% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cropbutton.
function cropbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cropbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Grab variables from workspace
x = evalin('base','x');
fileInfo = evalin('base','fileInfo');

for i = 1: size(x,1) %Loop through files
    if strcmp(x{i,2},'no') == 1
        
        for n = 1:size(fileInfo,1)
            if strcmp(x{i,1},fileInfo{n,1}) == 1
                index = n;
            end
        end
        
        I = char(strcat(fileInfo{index,2},fileInfo{index,1},'.jpg')); %Grab file name
        figure('units','normalized','outerposition',[0 0 0.5 0.5])
        imshow(I)
        descr = {'1. Drag Rectangle Outline for Crop   2. Right click  3. Select Crop Image 4. The cropped image will appear when done.';};
        title([fileInfo{index,1}],'Interpreter','none')
        text(0, -0.02, descr,'Units','normalized','FontSize',12)
        %User drags crop outline
        [Icrop,~] = imcrop; %Crop image
        if isempty(Icrop) == 0  %If the user selected an area to crop
            figure('units','normalized','outerposition',[0.5 0 0.5 0.5])
            imshow(Icrop); %Display Image
            title([fileInfo{index,1},'_crop',],'Interpreter','none')
            assignin('base',[fileInfo{index,1},'_crop'],Icrop); %Assign value to variable in specified workspace
            fileInfo{(size(fileInfo,1)+1),1} = strcat(fileInfo{index,1},'_crop');
            fileInfo{(size(fileInfo,1)),1} = strcat(fileInfo{index,2},'\Crop\');
            assignin('base','fileInfo',fileInfo)
            
            %SAVE CROPPED FILE TO CROP FOLDER
            cflder = strcat(fileInfo{index,2},'\Crop\');
            if isdir(cflder)== 0 %If the directory doesn't exist make it
                mkdir(cflder)
            end
            fname = strcat(fileInfo{index,2},'\Crop\',fileInfo{index,1},'_crop.jpg');
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
        else
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
%Grab variables from workspace
x = evalin('base','x');
fileInfo = evalin('base','fileInfo');

for i = 1: size(x,1) %Loop through files
    if strcmp(x{i,3},'no') == 1 && strcmp(x{i,2},'yes') == 1
        
        for n = 1:size(fileInfo,1)
            if strcmp(x{i,1},fileInfo{n,1}) == 1
                index = n;
            end
        end
        
        fname = char(strcat(fileInfo{index,2},fileInfo{index,1},'_crop.jpg')); %Grab file name
        I = evalin('base',fileInfo{index,1});
        t0 = evalin('base','t0');
        
        %Apply Tree
        for j=1:3
            RowS=I(:,:,j);
            all_rgb(:,j)=double(RowS(:));
        end
        ratioGR=all_rgb(:,2)./all_rgb(:,1);
        sumRGB=sum(all_rgb,2);
        data=[all_rgb,ratioGR,sumRGB];
        treeOut_x_0=treeval(t0,data);      
        %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead. 
        R=all_rgb(:,1);
        G=all_rgb(:,2);
        B=all_rgb(:,3);
        treeOut_x_0(B>G+40 & R>160)=4; %Blue Flowers
        treeOut_x_0(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS

        %Create Figure    
        szImg=size(RowS);
        m=szImg(1);
        n=szImg(2);
        yout = reshape(treeOut_x_0,m,n);
        
        assignin('base',[fileInfo{index,1},'_class'],yout); %Assign value to variable in specified workspace
        fileInfo{(size(fileInfo,1)+1),1} = strcat(fileInfo{index,1},'_class');
        fileInfo{(size(fileInfo,1)),1} = strcat(fileInfo{index,2},'\Classification\');
        assignin('base','fileInfo',fileInfo)
        
        %DISPLAY CLASSIFICATION RESULTS
        figure('units','normalized','outerposition',[0 0 0.5 0.5])
        subplot(1,2,1)%Original Image
        hold on
        title([fileInfo{index,1},': Original'],'Interpreter','none')
        imagesc(I)
        axis square
        hold off
        
        subplot(1,2,2) %Classification
        hold on
        title([fileInfo{index,1},': Classification'],'Interpreter','none')
        imagesc(yout)%Display image with scaled colors
        axis square
        hold on

        %SAVE CLASSIFICATION FILE TO CLASSIFICATION FOLDER
        cflder = strcat(fileInfo{index,2},'\Classification\');
        if isdir(cflder)== 0 %If the directory doesn't exist make it
            mkdir(cflder)
        end
        fname = strcat(fileInfo{index,2},'\Classification\',fileInfo{index,1},'_class.jpg');
        imwrite(yout,fname);
        
        x{i,3} = 'yes';
        assignin('base','x',x);
        
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
        break
    end
end   
update_table(handles)