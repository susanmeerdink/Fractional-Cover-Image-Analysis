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

% Last Modified by GUIDE v2.5 11-Jul-2016 08:41:24

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

if iscell(fnames) == 0  %If no or one file are selected
    if fnames == 0 %If no files are selected
        errordlg('No Files Selected','Error');
    else %if one file is selected
        fileInfo  = cell(1,1);
        varname = fnames;
        varname = char(strtok(varname,'.'));
        assignin('base',varname,importdata([folder,char(fnames)]));
        fileInfo{1,1} = varname;
        fileInfo{1,2} = folder;
        fileInfo{1,3} = 'Orig';
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames),'.');
        crop_path = strcat(folder,'Crop\',splitname(1),'_crop.',splitname(2));
        if exist(char(crop_path),'dir')
            varname = strcat(fnames,'_crop');
            folder = strcat(folder,'/Crop/');
            assignin('base',varname,importdata([folder,'\',char(varname)]));
            fileInfo{size(fileInfo,1)+1,1} = varname;
            fileInfo{size(fileInfo,1)+1,2} = folder;
            fileInfo{size(fileInfo,1)+1,3} = 'Crop';
        end

        %Check to see if classified files exist
        class_path = strcat(folder,'Class\',splitname(1),'_class.',splitname(2));
        if exist(char(class_path),'dir')
            varname = strcat(fnames,'_class');
            folder = strcat(folder,'/Class/');
            assignin('base',varname,importdata([folder,'\',char(varname)]));
            fileInfo{size(fileInfo,1)+1,1} = varname;
            fileInfo{size(fileInfo,1)+1,2} = folder;
            fileInfo{size(fileInfo,1)+1,3} = 'Class';
        end
        assignin('base','fileInfo',fileInfo);
        update_table(handles, 1)
    end   
else %if multiple files are selected
    fileInfo = cell(length(fnames),3);
    for n = 1:size(fnames,2) %Loop through files   
        varname = fnames(n);
        varname = char(strtok(varname,'.'));
        assignin('base',varname,importdata([folder,char(fnames(n))]));
        fileInfo{n,1} = varname;
        fileInfo{n,2} = folder;
        fileInfo{n,3} = 'Orig';
        
        %Check to see if cropped files exist
        splitname = strsplit(char(fnames(n)),'.');
        crop_path = strcat(folder,'Crop\',splitname(1),'_crop.',splitname(2));
        if exist(char(crop_path),'dir')
            varname = strcat(fnames(n),'_crop');
            folder = strcat(folder,'/Crop/');
            assignin('base',varname,importdata([folder,'\',char(varname)]));
            fileInfo{size(fileInfo,1)+1,1} = varname;
            fileInfo{size(fileInfo,1)+1,2} = folder;
            fileInfo{size(fileInfo,1)+1,3} = 'Crop';
        end
        
        %Check to see if classified files exist
        class_path = strcat(folder,'Class\',splitname(1),'_class.',splitname(2));
        if exist(char(class_path),'dir')
            varname = strcat(fnames(n),'_class');
            folder = strcat(folder,'/Class/');
            assignin('base',varname,importdata([folder,'\',char(varname)]));
            fileInfo{size(fileInfo,1)+1,1} = varname;
            fileInfo{size(fileInfo,1)+1,2} = folder;
            fileInfo{size(fileInfo,1)+1,3} = 'Class';
        end
    end
    clear i
    clear varname
    assignin('base','fileInfo',fileInfo); 
    update_table(handles, size(fnames,2))
end

function update_table(handles,var)
%Updating GUI table
x = cell(var,3);

%Update Table with new variables
vars = evalin('base','who');
isempty(strfind(vars{1},'_'))
strfind(vars{1},'DSCN')
for m = 1:length(vars) %Only show photos in listbox
    if strfind(vars{m},'DSCN') > 0 && isempty(strfind(vars{m},'_')) == 1 
        x{m,1} = vars{m};
    end
end

%Check if the photos have been cropped, update table status
for j = 1: size(x,1)
    test = strcmp(strcat(x{j},'_crop'),vars);
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
    test = strcmp(strcat(x{j},'_class'),vars);
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
        I = strcat(fileInfo{i,2},fileInfo{i,1},'.jpg'); %Grab file name
        figure
        imshow(I)
        title([x{i,1},': Drag Rectangle Outline for Crop'],'Interpreter','none')
        %User drags crop outline
        [Icrop,~] = imcrop; %Crop image
        if isempty(Icrop) == 0  %If the user selected an area to crop
            figure
            imshow(Icrop); %Display Image
            title([fileInfo{i,1},'_crop',],'Interpreter','none')
            assignin('base',[fileInfo{i,1},'_crop'],Icrop); %Assign value to variable in specified workspace
            %assignin('base',[fileInfo{i,1},'_crop_rect'],rect);
            %dirgui=evalin('base','dirstruct');
            %eval(['dirgui.',Ifname,'{4}=rect']);
            fileInfo{(size(fileInfo,1)+1),1} = strcat(fileInfo{i,1},'_crop');
            fileInfo{(size(fileInfo,1)+1),1} = strcat(fileInfo{i,2},'\Crop\');
            assignin('base','fileInfo',fileInfo)
            
            %SAVE CROPPED FILE TO CROP FOLDER
            cflder = strcat(fileInfo{i,2},'\Crop\');
            if isdir(cflder)== 0 %If the directory doesn't exist make it
                mkdir(cflder)
            end
            fname = strcat(fileInfo{i,2},'\Crop\',fileInfo{i,1},'_crop.jpg');
            imwrite(Icrop,fname)
            x{i,2} = 'yes';
        end
    end
    
end
update_table(handles,size(fileInfo,1))
