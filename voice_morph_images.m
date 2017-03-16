% voice_morph_batch.m
%
% creates voice morph trajectories using STRAIGHT toolbox and saves each as
% sound file, while also saving visualization of sound file (spectrogram) as
% image in data structure/matrix (.mat-format)
%
% last modified 03-09-17
% apj


% declare paths
if isunix
    VOICE_DIR                           = fullfile(filesep,'home',getUserName,...
                                            'Cloud2','movies','human','voices');
else
    VOICE_DIR                           = 'K:\ownCloud\movies\human\voices';
    if ~exist(VOICE_DIR,'dir')
        VOICE_DIR                       = 'C:\Users\adam\ownCloud\movies\human\voices';
    end
end
STRAIGHT_DIR                            = [fullfile(VOICE_DIR,'voice_overs','syllable') filesep];
ANCHOR_DIR                              = STRAIGHT_DIR;

TRAJ_DIRECTION_LIST                     = {'rad','tan'};

newXTickLabel                           = 0:.25:.5;
newYTickLabel                           = fliplr(0:5);

% order of voices
% [ george_orig male_1 female_1 female_2 randy male_3 male_4 arnold_1 male_5 ]

% order of faces
% [ arnold daniel hillary ian piers shinzo tom barney leftover ]

% load order of voices from .csv file
FID = fopen(fullfile(STRAIGHT_DIR,'reordered_nameList.csv'));
M = textscan(FID, '%s', 'Delimiter',','); % you will need to change the number   of values to match your file %f for numbers and %s for strings.
M = M{:};
M = M(cellfun(@isempty,strfind(M,'voiceAve')));
fclose(FID);
% OOF                                     = regexp(M,'\d+(\.)?','match');
% VOICE_ORDER                             = nan(1,length(OOF));
% for i = 1:length(OOF)
%     FOO                                 = OOF{i};
%     VOICE_ORDER(i)                      = str2double(FOO{1});
% end
VOICE_ORDER                             = [3, 1, 4, 5];
VOICE_CIRC                              = [VOICE_ORDER VOICE_ORDER(1)];
% VOICE_ORDER                             = [8 2 3 9 4 5 7 1 6];

IMAGE_MAT.ORDER                         = VOICE_ORDER;

% add STRAIGHT tools to path
addpath(genpath(fullfile(VOICE_DIR,'STRAIGHT_path_package')))

% specify STRAIGHT-object files
foo                                     = textscan(sprintf('StrObj%d.mat ',1:8),'%s');
STR_OBJ_LIST                            = foo{:};
VOICENUM                                = length(STR_OBJ_LIST);

% specify their corresponding anchors
foo                                     = textscan(sprintf('targetAnchorStrObj%d.mat ',1:7),'%s');
STR_ANCH_LIST                           = [{'referenceAnchorStrObj.mat'}; foo{:}];
ANCHOR_FILELIST                         = STR_ANCH_LIST;

STRAIGHT_FILENAMES                      = cell(1,length(STR_OBJ_LIST));
for i = 1:length(STRAIGHT_FILENAMES)
    load([STRAIGHT_DIR,STR_OBJ_LIST{i}])
    STRAIGHT_FILENAMES{i}               = STRAIGHTobject.dataFileName;
    STRAIGHTobject.morphingMenu.delete
end

% print table summarizing face-morphs
T                                       = table(STR_OBJ_LIST,ANCHOR_FILELIST,'RowNames',STRAIGHT_FILENAMES);
disp(T)

% save text file specifying details of voice morphs to be done
SPECFILE_NAME                           = fullfile(STRAIGHT_DIR,'specification_file.txt');
SPECFILE_ID                             = fopen(SPECFILE_NAME,'w');
TEXTOUT                                 = [{['mRate ' repmat(sprintf('%.4f ',1/VOICENUM),...
    1,VOICENUM)]}; {['STRAIGHTDirectory ' STRAIGHT_DIR]};
    STR_OBJ_LIST; {['anchorStructDirectory ' ANCHOR_DIR]}; ANCHOR_FILELIST];
for ROW = 1:length(TEXTOUT)
    fprintf(SPECFILE_ID,'%s\n',TEXTOUT{ROW,:});
end
fclose(SPECFILE_ID);

% create voice object
VOICE_OBJ                               = temporallyStaticBatchMorphingR3(SPECFILE_NAME);
FS                                      = VOICE_OBJ.synthStructure.samplingFrequency;

%% create voice average
MORPH_SPEC_AVE                          = ones(1,VOICENUM)/VOICENUM;
MORPH_OBJ                               = staticMorphing(VOICE_OBJ.objectBundleSs,MORPH_SPEC_AVE);
MORPH_AVE_SYNOUT                        = MORPH_OBJ.synthStructure.synthesisOut;

% save average voice as sound file
FILE_NAME                               = fullfile(STRAIGHT_DIR,'voice_stim','voiceAve.wav');
audiowrite(FILE_NAME,MORPH_AVE_SYNOUT,FS)
disp(['file saved: ' FILE_NAME])

% get spectrogram image (and alpha channel)
[SPECT_IMG,ALPHA,~]                     = get_STRAIGHTspectrogram(MORPH_OBJ);
IMAGE_MAT.AVE                           = cat(3,SPECT_IMG,ALPHA);                           

% declare number of steps on each trajectory
STEP_NUM                                = 4;
STEPS                                   = 1/STEP_NUM:1/STEP_NUM:1;

%% step through voice identities
for I = 1:length(VOICE_ORDER)
    
    % create empty vectors for level of each voice
    MORPH_SPEC_RAD                      = nan(1,VOICENUM);
    MORPH_SPEC_TAN                      = nan(1,VOICENUM);
    
    % step through morph levels along each trajectory
    for II = 1:length(STEPS)
        
        %% radial trajectory
        % specificy voice identity content
        MORPH_SPEC_RAD(VOICE_ORDER(I))  = STEPS(II);
        GROUP_VOICES                    = setdiff(1:VOICENUM,VOICE_ORDER(I));
        MORPH_SPEC_RAD(GROUP_VOICES)    = (1-STEPS(II))/(VOICENUM-1);
        
        % create voice morph
        MORPH_OUT_RAD                   = staticMorphing(VOICE_OBJ.objectBundleSs,MORPH_SPEC_RAD);
        MORPH_OUT_RAD_SYNOUT            = MORPH_OUT_RAD.synthStructure.synthesisOut;
        
        % get spectrogram image (and alpha channel)
        [SPECT_IMG_RAD,ALPHA_RAD,~]     = get_STRAIGHTspectrogram(MORPH_OUT_RAD);
        IMAGE_MAT.RAD{I,II}             = cat(3,SPECT_IMG_RAD,ALPHA_RAD);
        
        %% save rad voice as sound file
        FILE_NAME                       = fullfile(STRAIGHT_DIR,'voice_stim',...
                                    ['voice' num2str(VOICE_ORDER(I)) '_rad_' ...
                                    sprintf('%03d',round(STEPS(II)*100)) '%.wav']);
        audiowrite(FILE_NAME,MORPH_OUT_RAD_SYNOUT,FS)
        disp(['file saved: ' FILE_NAME])
        
%         % make speech-shaped noise and save as sound file
%         FILE_NAME                       = fullfile(STRAIGHT_DIR,'voice_stim',...
%                                     ['voice' num2str(VOICE_ORDER(I)) '_rad_' ...
%                                     sprintf('%03d',round(STEPS(II)*100)) '%_noisy.wav']);
%         audiowrite(FILE_NAME,SSN(MORPH_OUT_RAD_SYNOUT),FS)
        
        %% tangential trajectory
        if II<4

            % set up morph for current tangential voice pair
            MORPH_SPEC_TAN(VOICE_CIRC(I:I+1))         = STEPS([II length(STEPS)-II]);
            % set others to zero
            MORPH_SPEC_TAN(setdiff(1:VOICENUM,VOICE_CIRC(I:I+1)))   = 0;
            
            % create voice morph
            MORPH_OUT_TAN               = staticMorphing(VOICE_OBJ.objectBundleSs,MORPH_SPEC_TAN);
            MORPH_OUT_TAN_SYNOUT        = MORPH_OUT_TAN.synthStructure.synthesisOut;
            
            % get spectrogram image (and alpha channel)
            [SPECT_IMG_TAN,ALPHA_TAN,~] = get_STRAIGHTspectrogram(MORPH_OUT_TAN);
            IMAGE_MAT.TAN{I,length(STEPS)-II}         = cat(3,SPECT_IMG_TAN,ALPHA_TAN);
            
            %% save tan morph voice as sound file
            if II<4
                
                FILE_NAME               = fullfile(STRAIGHT_DIR,'voice_stim',...
                    ['voice' num2str(VOICE_ORDER(I)) '_tan_' ...
                    sprintf('%03d',round(STEPS(end-II)*100)) '%.wav']);
                audiowrite(FILE_NAME,MORPH_OUT_TAN_SYNOUT,FS)
                disp(['file saved: ' FILE_NAME])
                
%                 % make speech-shaped noise and save as sound file
%                 FILE_NAME               = fullfile(STRAIGHT_DIR,'voice_stim',...
%                                     ['voice' num2str(VOICE_ORDER(I)) '_tan_' ...
%                                     sprintf('%03d',round(STEPS(II)*100)) '%_noisy.wav']);
%                 audiowrite(FILE_NAME,SSN(MORPH_OUT_TAN_SYNOUT),FS)

            end
        end
    end
end

%% save data
SAVE_NAME                               = fullfile(STRAIGHT_DIR,'voice_morph_space');
save([SAVE_NAME '.mat'],'IMAGE_MAT')

delete(findall(0,'Type','figure'))
% close all
