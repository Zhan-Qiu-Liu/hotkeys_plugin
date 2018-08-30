function XformDNS_BV2Epi(button,config,self)
% XformDNS_BV2Epi  - transform .dns inFiles of SA and LA
%
%
%	transform .dns inFiles from Version 0.4 2009.06 to Version: 0.5
%
%
% USAGE:
%   XformDNS_BV2Epi();
%
%
% See also:
%   
%
% Last Modified: 11:25 January 24, 2018
% Copyright (c) Zhanqiu Liu (lafeir.lew@gmail.com)

	% dbstop if error
	
	%% DIRECTORY LOAD: default inputs
	homepath = char(java.lang.System.getProperty('user.home'));
	pathDNS = [homepath,'\Dropbox\Analysis']%Directory where DNS stored by default
	pathMAT = [homepath,'\Dropbox\MAT']%Directory where DENSE2D outputs(post-analyzed .MAT) stored by default

	if ~exist('button','var')
		button = input('Press any key for using a User Interface to select Datasets of interest.\nOtherwise leave it blank!\n','s');
	end
	
	if isempty(button)
		tmp = dir(pathDNS); files = {tmp.name}; idx = strwcmpi(files,'*.dns'); files = files(idx);	
		tmp = arrayfun(@num2str, 1:numel(files), 'UniformOutput', false);
		tmp = strcat(tmp, '.', files);
		idx = input(strcat([sprintf('%s\n',tmp{:}),'Input a MATRIX of the numbers of Datasets of interest[use Space/Space/Semicolon(;) to seperate]:']));
		idx = reshape(idx,[],1); idx = round(abs(idx)); idx(idx==0) = [];
		% Default input datasets:
		if isempty(idx)
			idx = [9 19 8 18 5 15 6 16 7 17];
			files(idx)
		end
		files = files(idx);
		inFiles = fullfile(pathDNS,files);
	else
		clear inFiles files;
		ii = 0;
		if exist('config','var')
			pathDNS = config;
		end
		while true
			[uifile, uipath, uipopup] = uigetfile({'*.dns','DENSE2D(v0.4) workspace(*.dns)'},'Select DNS file',pathDNS);
			if ~uipopup %isequal(uifile,0) || isequal(uipath,0)
				break
			else
				ii = ii + 1;
				inFiles{ii} = fullfile(uipath,uifile);
				files{ii} = uifile;
				if strcmpi(pathDNS, fullfile(uipath, uifile))
					pathDNS = uipath;%fileparts(pathDNS);
					break
				end
			end
		end
	end
	if ~exist('files','var'); return; end;
	nFiles = numel(files);
		
	if isempty(button)
		tmp = {'[Use the Data Cursor tool to confirm the directions of X-axis and Y-axis]','From X-axis to Y-axis: ','Press ENTER for ClockWise (rightward X-axis and downward Y-axis)','ANY INPUTS for CounterClockWise (rightward X-axis and upward Y-axis)','Your observation:'};%or input "CW"
		clcDir = input(strcat([sprintf('%s\n',tmp{:})]),'s');
		if isempty(clcDir)
			clcDir = -1;
			% dir_clc = 'CW';
		else
			clcDir = 1;		
			% dir_clc = 'CCW';		
		end		
	else
		clcDir = questdlg({'[Use the Data Cursor tool to confirm the directions of X-axis and Y-axis]','From X-axis to Y-axis: ','ClockWise? (rightward X-axis and downward Y-axis)'},'Clock Direction of Image Coordinate System');
		if strcmpi(clcDir,'Yes')
			clcDir = -1;		
		else
			clcDir = 1;		
		end
	end	
	
	if ~exist('self','var')
		self.aside = struct('ant',3,'pos',0);
	end
	%% Setting of distance of Endo-RV-insertPT away from Epi-RV-insertPT in SA view:
	while true
		if isempty(button)
			tmp = {'Input a INTEGER from -60 to 120:','+1 for setting Anterior-Endo-RV-insertPT 17 degree away from Anterior-Epi-RV-insertPT in the CCW direction','[Press ENTER for the default value]:'};%{['Input a INTEGER:','+1 for setting Anterior-Endo-RV-insertPT 17 degree away from Anterior-Epi-RV-insertPT in the ',clcDir,' direction'],'Sign Convention:','Input ANY STRINGS EXCEPT "yes"'}
			self.aside.ant = input(strcat([sprintf('%s\n',tmp{:})]));
			if isempty(self.aside.ant)
				self.aside.ant = 3;
			end
		else
			self.aside.ant = inputdlg('Input a INTEGER from -60 to 120: +1 for setting Anterior-Endo-RV-insertPT 17 degree away from Anterior-Epi-RV-insertPT in the CCW direction','Observe the outFiles and Adjust: Positive=CCW!',1,{num2str(self.aside.ant)});
			self.aside.ant = sscanf(sprintf('%s*', self.aside.ant{:}), '%f*');
			% self.aside.ant = str2num(self.aside.ant{:});%slow
		end
		if mod(self.aside.ant,1)==0 % self.aside.ant >= 0 || isinteger(self.aside.ant)
			break
		end		
	end
	while true
		if isempty(button)
			tmp = {'Input a INTEGER from -60 to 120:','+1 for setting Posterior-Endo-RV-insertPT 17 degree away from Posterior-Epi-RV-insertPT in the CCW direction','[Press ENTER for the default value]:'};
			self.aside.pos = input(strcat([sprintf('%s\n',tmp{:})]));
			if isempty(self.aside.pos)
				self.aside.pos = 0;
			end
		else
			self.aside.pos = inputdlg('Input a INTEGER from -60 to 120: +1 for setting Posterior-Endo-RV-insertPT 17 degree away from Posterior-Epi-RV-insertPT in the CCW direction','Observe the outFiles and Adjust: Positive=CCW!',1,{num2str(self.aside.pos)});
			self.aside.pos = sscanf(sprintf('%s*', self.aside.pos{:}), '%f*');
		end
		if mod(self.aside.pos,1)==0
			break
		end		
	end
	
	%% Setting of distance of Endo-RV-insertPT away from Epi-RV-insertPT in LA view:
	self.aside.LA = 1;
	
	% Define some constants:
	old = {'curve','line','SAFull', 'LAFull'};
	new = {'curved','poly','sadual','ladual'};
	% ROITYpe:
	% rois.CurvedRegion; rois.PolylineRegion; rois.LVShortAxis; rois.LVLongAxis; rois.ClosedContour; rois.OpenContour; plugins.dense3D_plugin.SADualContour; plugins.dense3D_plugin.LADualContour; 
	nText = numel(old);
	%% Setting of #ofPoints of SA RV-endo:
	% 12 pts for SA RV-endo by default(#1 & #7 are corner pts):
	nRVendoPt = 12;% got to be even
	RVendoCorner = repmat(false, [nRVendoPt,1]); RVendoCorner(1) = true; RVendoCorner(nRVendoPt/2+1) = true;
	
	for ii = 1 : nFiles
		%% test:
		% load(fullfile(pathDNS,'20150628.dns'),'-mat');
		load(inFiles{ii},'-mat');
		if ~all(cellfun(@(x)exist(x,'var'),{'seq','img','dns','roi'}))
			msgbox('".dns" file does not contain the necessary information');
		end
		
		%load DENSE2D outputs(post-analyzed .MAT)
		tmp = numel(files{ii});
		if  tmp > 7
			idx = 8;
		elseif tmp == 4
			idx = 4;
		else
			error('Variable "status" NOT exist!');
			msgbox(['The length of inFile name ',files{ii},' is NOT supported! Supported length > 7 OR == 4'],'s');
		end
		pathPostMAT = [pathMAT,'\',files{ii}(1:idx)];
		if exist(pathPostMAT,'dir')
			MagIndex = reshape([dns.MagIndex],3,[]);MagIndex = MagIndex(1,:);
			tmp = dir(pathPostMAT);
			tmp = {tmp.name};
			pathDNSori = [pathDNS,'\',files{ii}(1:idx),'.dns'];
			if ~exist('status','var') && exist(pathDNSori,'file')
				load(pathDNSori,'status','-mat');
			end
			if exist('status','var')
				tmp1 = find(strncmpi(tmp, dns(status.SOI(1)).Name, 6));	
				pathAnalysisMAT = [pathPostMAT,'\',tmp{tmp1(1)}];
			else
				tmp1 = strncmpi(tmp, 'auto.', 5);
				tmp2 = find(tmp1);
				pathAnalysisMAT = [pathPostMAT,'\',tmp{tmp2(ceil(sum(tmp1)/2))}];
				% msgbox('Variable "status" NOT exist!','s');
				% return
			end
			load(pathAnalysisMAT, 'AnalysisInfo', '-mat');
			if ~isnan(AnalysisInfo.SegDistribution{1, 2})
				SegPos = AnalysisInfo.SegDistribution{1, 2};
			else
				SegPos = 15
			end
		else
			msgbox(['CANNOT FOUND the directory where DENSE2D outputs stored for the input',files(ii),'A update is required for the Codes!']);
			break				
			%{ 
			clckPOS = input('The Longitudinal Ventricular Location of Insertion Points of interest[press enter for "Mid", "1" for Base, "2" for "Apex", "3" for "Whole", "4" for "Average"; or Input a n-by-2 Matrix]: ');
			if isempty(clckPOS)
				clckPOS = 'Mid';
			end							
			SeptumRatio = 
			AnalysisInfo.PositionB =
			SegPos/60*360
			 %}
		end

		nROI = numel(roi);

		% Clear points of SA RV-endo:
		RVendo = zeros(nRVendoPt,2);
		
		idx = find(strcmpi({roi.Type},'SA'));
		% idx = strcmpi({roi.Type},'SA');
		if ~isempty(idx)
		for jj = idx
		% for jj = find(idx)
			roiName = [dns(MagIndex == roi(jj).SeqIndex(1)).Name,'_',roi(jj).Name];
			pathAnalysisMAT = [pathPostMAT,'\',roiName,'.mat'];
			if ~exist(pathAnalysisMAT,'file')
				[uifile, uipath] = uigetfile({'*.mat','DENSE2D(v0.4) outputs(post-analyzed *.MAT)'},['Select MAT file for SA ROI:',roiName,' of the input:',files{ii}],pathPostMAT);
				if isequal(uipath,0) || isequal(uifile,0)
					break
				end
				pathAnalysisMAT = fullfile(uipath,uifile);					
			end
			load(pathAnalysisMAT, 'AnalysisInfo','DisplacementInfo', '-mat')

			idx1 = find(strcmpi({roi.Name},'Short Axis Dual Ventricle'));
			idx2 = cellfun(@(x)isequal(x,roi(jj).SeqIndex), {roi(idx1).SeqIndex});%,'UniformOutput', false)
			switch sum(idx2)
				case 1
					ROI = idx1(idx2);
				case 0
					nROI = nROI + 1;
					ROI = nROI;
				otherwise
					msgbox(['Duplicate converted ROIs detected:',num2str(sum(idx1)),' converted ROIs found for the SA ROI:',roiName,' of the input',files(ii)]);
					break
			end
			
			roi(ROI).Name = 'Short Axis Dual Ventricle';
			roi(ROI).Type = 'sadual';
			roi(ROI).UID = dicomuid;
			roi(ROI).SeqIndex = roi(jj).SeqIndex;
			nFrames = size(roi(jj).Position,1);
			roi(ROI).IsClosed = repmat({true}, [nFrames,3]);
			roi(ROI).IsCurved = repmat({true}, [nFrames,3]);
			% roi(jj).IsCurved = repmat({true}, [nFrames,2]);
			roi(jj).IsCurved = cellfun(@logical,roi(jj).IsCurved,'UniformOutput',false);
			roi(ROI).IsCorner = repmat({false}, [nFrames,3]);
			% roi(ROI).IsCorner = repmat({false,false,RVendoCorner}, [nFrames,1]);
			% roi(jj).IsCorner = repmat({false}, [nFrames,2]);
			roi(jj).IsCorner = cellfun(@logical,roi(jj).IsCorner,'UniformOutput',false);
			
			roi(ROI).Position = roi(jj).Position;
			% roi(ROI).Position{:, 2} = roi(jj).Position{:, 2};
			idx1 = cellfun(@isempty, roi(jj).Position);
			if ~isequal(idx1(:,1),idx1(:,2))
				msgbox(['Missing LV-endo or LV-epi countours for the SA ROI:',roiName,' of the input',files(ii)]);			
			end
			idx1 = find(~idx1(:,1))'; % idx1(:,2) = [];
			
			if isempty(idx1)
				if ROI < numel(roi)
					msgbox(['No contours found in the SA ROI:',roiName,' of the input',files(ii),'But it has been converted before!']);
					return
				else
					roi(ROI) = [];
					nROI = nROI - 1;
				end				
				break;
			else
				for kk = idx1
					roi(ROI).IsCorner{kk,3} = RVendoCorner;
					% roi(ROI).IsCorner{kk,3} = false;
					
					%% Project InsertPt:
					dx = fnvalmod(DisplacementInfo.spldx,[AnalysisInfo.PositionB([2 1]),kk]');
					dy = fnvalmod(DisplacementInfo.spldy,[AnalysisInfo.PositionB([2 1]),kk]');
					InsertPt = AnalysisInfo.PositionB + [dx,dy];
					% NO PIXEL# FOUND!:find(abs(DisplacementInfo.dX(:,kk)-dx) < 1e-04)
					% InsertPt = AnalysisInfo.PositionB+[DisplacementInfo.dX(:,kk),DisplacementInfo.dY(:,kk)];
					
					%% Interpolation
					% Need a closed circle:
					LVepi = [roi(jj).Position{kk, 1};roi(jj).Position{kk, 1}(1,:)];
					nSamplePt = size(LVepi,1);
					% AnalysisInfo.Nmodel = 60: not stored!
					LVepiInterp(:,1) = spline(1:nSamplePt, LVepi(:,1), 1:(nSamplePt-1)/59:nSamplePt);
					LVepiInterp(:,2) = spline(1:nSamplePt, LVepi(:,2), 1:(nSamplePt-1)/59:nSamplePt);
					%% find nearest point:
					tmp = bsxfun(@minus,LVepiInterp,InsertPt);
					[~,idx_AntInsPt] = min(sum(tmp.^2,2));
					
					%% Insert 2 RVinsertPts into LVepi
					% find nearest point: work for over-flat LVepi- ellipse
					if clcDir == -1
						LVepiInterp_ReOrd = LVepiInterp([idx_AntInsPt:-1:1,end:-1:idx_AntInsPt+1],:);
					else
						LVepiInterp_ReOrd = LVepiInterp([idx_AntInsPt:end,1:idx_AntInsPt-1],:);
					end
					for ll = [1,SegPos]
						LVepi = roi(ROI).Position{kk,1};
						tmp = bsxfun(@minus,LVepi,LVepiInterp_ReOrd(ll,:)); 
						[~,idx2] = sort(sum(tmp.^2,2),'ascend');
						if abs(idx2(1)-idx2(2)) > 1
							msgbox(['Insertion points NOT SAVED in the LVepi since random order of LVendo- points stored at the frame#',num2str(kk),'for the SA ROI:',roiName,' of the input',files(ii)]);
							break
						end
						idx3 = sort(idx2(1:2),'ascend');
						v1 = LVepi(idx2(2),:)-LVepi(idx2(1),:); v2 = LVepiInterp_ReOrd(ll,:)-LVepi(idx2(1),:);
						% angle bet 2 vectors = mod(-180/pi * angle, 360);
						if atan2(abs(det([v1;v2])),dot(v1,v2)) < pi/2
							roi(ROI).Position{kk,1} = [LVepi(1:idx3(1),:);LVepiInterp_ReOrd(ll,:);LVepi(idx3(2):end,:)];
						elseif idx2(1) < idx2(2)
							roi(ROI).Position{kk,1} = [LVepi(1:idx2(1)-1,:);LVepiInterp_ReOrd(ll,:);LVepi(idx2(1):end,:)];						
						else % idx2(1) > idx2(2)
							roi(ROI).Position{kk,1} = [LVepi(1:idx2(2),:);LVepiInterp_ReOrd(ll,:);LVepi(idx2(2)+1:end,:)];
						end
					end
					
					%% Generate RVendo:
					idx3 = idx_AntInsPt+clcDir*self.aside.ant;
					if idx3 < 1
						idx3 = 60 + idx3;
					elseif idx3 > 60
						idx3 = idx3 - 60;					
					end
					if clcDir == -1
					% if strcmpi(dir_clc,'CW')
					%% LV points stored CW under rightward X-axis and downward Y-axis: 
						LVepiInterp_ReOrd = LVepiInterp([idx3:-1:1,end:-1:idx3+1],:);
					else
					%% LV points stored CCW under rightward X-axis and upward Y-axis(common coord. sys.):
						LVepiInterp_ReOrd = LVepiInterp([idx3:end,1:idx3-1],:);
					end
					RVendo(1,:) = LVepiInterp_ReOrd(1,:);
					SegPos_new = SegPos - self.aside.ant + self.aside.pos;
					if SegPos_new < 1
						msgbox(['Wrong selections: Posterior-aside-distance ',self.aside.pos,'is too large in magnitude compared with ','Anterior-aside-distance ',self.aside.ant]);
						return				
					end
					RVendo(nRVendoPt/2+1,:) = LVepiInterp_ReOrd(SegPos_new,:);
					interval = round((SegPos_new-1)/(nRVendoPt/2));
					%{ 
					interval = (SegPos_new-1)/(nRVendoPt/2);
					if mod(interval,1) > 0.6
						interval = ceil(interval);					
					else
						interval = floor(interval);
					end
					 %}
					LVendo = roi(jj).Position{kk, 2};
					center = mean(LVendo);
					% center = mean([mean(LVepi);mean(LVendo)])=AnalysisInfo.PositionA+[dx,dy]?
					% tmp = bsxfun(@minus,LVendo,center); rad = mean(sqrt(sum(tmp.^2,2)));
					v1 = (RVendo(nRVendoPt/2+1,:)+RVendo(1,:))/2-center;
					% v1 = RVendo(nRVendoPt/2+1,:)-RVendo(1,:); v1 = [v1(2),-v1(1)];
					v1 = v1/norm(v1);
					v2 = (RVendo(nRVendoPt/2+1,:)-RVendo(1,:));
					for ll = 1:nRVendoPt/2-1
						RVendo(1+ll,:) = LVepiInterp_ReOrd(1+interval*ll,:);
						% RVendo(end+1-ll,:) = RVendo(1+ll,:) + v1*rad;
						tmp = dot(v2, RVendo(1+ll,:) - RVendo(1,:)) / dot(v2, v2);
						intersectPt = RVendo(1,:) + tmp * v2;
						dist = norm(RVendo(1+ll,:)-intersectPt);
						RVendo(end+1-ll,:) = RVendo(1+ll,:) + v1*dist;
					end
					roi(ROI).Position{kk,3} = RVendo;
					
					% if kk == 3; breakpoint; end;
					
%{ 			
% Validate RVendo generation:
figure
% plot(LVepi(:,1),LVepi(:,2),'LineWidth',1,'color','b','Marker','x','MarkerSize',5);
plot(roi(ROI).Position{kk,1} (:,1),roi(ROI).Position{kk,1} (:,2),'LineWidth',1,'color', 'b','Marker', 'x', 'MarkerSize',5); 
hold on;
plot(LVendo(:,1),LVendo(:,2),'LineWidth',1,'color', 'r','Marker', '+', 'MarkerSize',5); 
title('Validate RVendo generation!');
plot(RVendo(:,1),RVendo(:,2),'LineWidth',1,'color', 'k','Marker', '+', 'MarkerSize',5); 
set(gca,'Ydir','reverse');
axis equal;
plot(LVepiInterp(1,1),LVepiInterp(1,2),'LineWidth',1,'color', 'k','Marker', 'o', 'MarkerSize',10);
plot(LVepiInterp(4,1),LVepiInterp(4,2),'LineWidth',1,'color', 'k','Marker', 's', 'MarkerSize',10);
plot(LVepiInterp(SegPos,1),LVepiInterp(SegPos,2),'LineWidth',1,'color', 'k','Marker', 'd', 'MarkerSize',10);
% plot(InsertPt(1,1),InsertPt(1,2),'LineWidth',1,'color', 'k','Marker', 'o', 'MarkerSize',10);
% plot(RVendo(1,1),RVendo(1,2),'LineWidth',1,'color', 'k','Marker', 'o', 'MarkerSize',5);
% plot(RVendo(nRVendoPt/2+1,1),RVendo(nRVendoPt/2+1,2),'LineWidth',1,'color', 'k','Marker', 'o', 'MarkerSize',5);		
% plot(AnalysisInfo.PositionB(1),AnalysisInfo.PositionB(2),'color', 'k','Marker', 'o', 'MarkerSize',10);
% plot(ROIInfo.Contour{kk, 1}(1,1),ROIInfo.Contour{kk, 1}(1,2),'LineWidth',1,'color', 'k','Marker', 'x', 'MarkerSize',10);
figure
plot(LVepiInterp(:,1),LVepiInterp(:,2),'LineWidth',1,'color', 'k');
axis equal;
 %}
				end
			end
		end
		end
		
		idx = find(strcmpi({roi.Type},'LA'));
		idx1 = strcmpi({roi(idx).Name},'Auto Generated LA'); idx(idx1) = [];
		if ~isempty(idx)
		for jj = idx
			roiName = [dns(MagIndex == roi(jj).SeqIndex(1)).Name,'_',roi(jj).Name];
			idx1 = find(strcmpi({roi.Name},'Long Axis Dual Ventricle'));
			idx2 = cellfun(@(x)isequal(x,roi(jj).SeqIndex), {roi(idx1).SeqIndex});
			switch sum(idx2)
				case 1
					ROI = idx1(idx2);
				case 0
					nROI = nROI + 1;
					ROI = nROI;
				otherwise
					msgbox(['Duplicate converted ROIs detected:',num2str(sum(idx1)),' converted ROIs found for the LA ROI:',roiName,' of the input',files(ii)]);
					break
			end
			
			roi(ROI).Name = 'Long Axis Dual Ventricle';
			roi(ROI).Type = 'ladual';
			roi(ROI).UID = dicomuid;
			roi(ROI).SeqIndex = roi(jj).SeqIndex;
			nFrames = size(roi(jj).Position,1);
			roi(ROI).IsClosed = repmat({false}, [nFrames,3]);
			roi(jj).IsCurved = cellfun(@logical,roi(jj).IsCurved,'UniformOutput',false);
			% roi(ROI).IsCurved = [roi(jj).IsCurved,roi(jj).IsCurved(:,2)];
			roi(ROI).IsCurved = roi(jj).IsCurved;
			roi(jj).IsCorner = cellfun(@logical,roi(jj).IsCorner,'UniformOutput',false);
			roi(ROI).IsCorner = roi(jj).IsCorner;
			
			roi(ROI).Position = roi(jj).Position;			
			idx1 = cellfun(@isempty, roi(jj).Position);
			if ~isequal(idx1(:,1),idx1(:,2))
				msgbox(['Missing LV-endo or LV-epi countours for the LA ROI:',roiName,' of the input',files(ii)]);			
			end
			idx1 = find(~idx1(:,1))';
			if isempty(idx1)
				if ROI < numel(roi)
					msgbox(['No contours found in the LA ROI:',roiName,' of the input',files(ii),'But it has been converted before!']);
					return
				else
					roi(ROI) = [];
					nROI = nROI - 1;
				end				
				break;
			else
				for kk = idx1			
					LVepi = roi(jj).Position{kk, 1};
					LVendo = roi(jj).Position{kk, 2};
					EpiApex = size(LVepi,1); EpiApex = (EpiApex+1)/2;
					EndoApex = size(LVendo,1); EndoApex = (EndoApex+1)/2;
					if floor(EpiApex)~=EpiApex || floor(EndoApex)~=EndoApex
					%% NOT FAIL for inf: 
					% if mod(EpiApex,1)~=0 || mod(EndoApex,2)~=0
						msgbox(['CANNOT FOUND the APEX because of the even number of LV contour points for the input',files(ii),'A update is required for the Codes!']);
						break
					end
					nRVendoPt = 2*(EpiApex-self.aside.LA)-1;%size(LVepi,1)-2*self.aside.LA;
					roi(ROI).IsCurved{kk, 3} = repmat(true, [nRVendoPt,1]);
					roi(ROI).IsCorner{kk, 3} = repmat(false, [nRVendoPt,1]);
					% maximum curvature here: err for max(inf)?
					roi(ROI).IsCorner{kk, 3}(EpiApex-self.aside.LA) = true;
					
					if LVepi(1,1)-LVepi(EpiApex,1) < LVepi(EpiApex,1)-LVepi(EpiApex,1)
						LVepi = LVepi(end:-1:1,:);
						LVendo = LVendo(end:-1:1,:);
					end
					v2 = LVepi(EpiApex,:)-LVendo(EndoApex,:);
					RVendo = [LVepi(1:EpiApex-self.aside.LA,:);zeros(EpiApex-1-self.aside.LA,2)];
					for ll = 1:EpiApex-1-self.aside.LA
						tmp = dot(v2, LVendo(ll,:) - LVendo(EndoApex,:)) / dot(v2, v2);
						intersectPt = LVendo(EndoApex,:) + tmp * v2;
						dist = norm(LVendo(ll,:)-intersectPt);
						v1 = LVepi(ll,:) - LVendo(ll,:); v1 = v1/norm(v1);
						RVendo(end+1-ll,:) = LVepi(ll,:) + v1*dist;
						thk = norm(LVepi(ll,:) - LVendo(ll,:));
						roi(ROI).Position{kk,1}(ll,:) = RVendo(end+1-ll,:) + v1*thk/3;
					end
					ll = EpiApex-self.aside.LA;
					v1 = LVepi(ll,:) - LVendo(ll,:); v1 = v1/norm(v1);
					thk = norm(LVepi(ll,:) - LVendo(ll,:));
					roi(ROI).Position{kk,1}(ll,:) = RVendo(ll,:)+v1*thk/3;
					
					roi(ROI).Position{kk,3} = RVendo;
%{ 			
% Validate RVendo generation:
figure
plot(LVepi(:,1),LVepi(:,2),'LineWidth',1,'color','b','Marker','x','MarkerSize',5);
hold on;
plot(LVendo(:,1),LVendo(:,2),'LineWidth',1,'color', 'r','Marker', '+', 'MarkerSize',5); 
title('Validate RVendo generation!');
plot(RVendo(:,1),RVendo(:,2),'LineWidth',1,'color', 'r','Marker', '+', 'MarkerSize',5); 
set(gca,'Ydir','reverse');
axis equal;

figure
plot(roi(ROI).Position{kk,1}(:,1),roi(ROI).Position{kk,1}(:,2),'LineWidth',1,'color','b','Marker','x','MarkerSize',5);
hold on;
plot(roi(jj).Position{kk, 2}(:,1),roi(jj).Position{kk, 2}(:,2),'LineWidth',1,'color', 'r','Marker', '+', 'MarkerSize',5); 
title('Validate RVendo generation!');
plot(roi(ROI).Position{kk,3}(:,1),roi(ROI).Position{kk,3}(:,2),'LineWidth',1,'color', 'r','Marker', '+', 'MarkerSize',5); 
set(gca,'Ydir','reverse');
axis equal;
 %}
					end
			end
		end
		end
		
		% Make compatible:
		for kk = 1 : nText
			idx = find(strcmpi({roi.Type},old{kk}));
			if ~isempty(idx)
				for jj = idx
					roi(jj).Type = new{kk};%Err if new(kk) will make roi.Type as cell instead of char
				end
			end
		end
		
		%% Save outFiles:
		[~,fname] = fileparts(files{ii});
		if strwcmpi(fname,'*_v05')
			outFiles{ii} = inFiles{ii}
		else
			outFiles{ii} = [pathDNS,'\',fname,'_v05.dns'];
		end
		
		if nFiles == 1
			uifile = 0;
			while isequal(uifile,0)
				[uifile, uipath] = uiputfile({'*.dns', 'Save a DENSE2D(v0.1.0) workspace (*.dns)'},'Save DNS file', outFiles{ii});
				if isequal(uipath,0) || isequal(uifile,0)
					button = questdlg('Do you wanna quit? You might lose data!','Warning');
					if strcmpi(button,'Yes')
						return
					end
				end
				%% Append the correct file extension if needed
				[~,fname] = fileparts(uifile);
				outFiles{ii} = [uipath,fname,'.dns'];
			end
		end
			
		save(outFiles{ii}, 'seq','img','dns','roi');
		
	end
	
end







