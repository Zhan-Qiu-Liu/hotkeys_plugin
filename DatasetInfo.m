function DatasetInfo(handles,dense)
	%
	% INPUTS:
	%   self:   Object,  Instance of the TestPlugin object
	%   handles:    struct, guidata structure from the DENSEanalysis
	%               GUI. This provides access to all data and controls 
	%               in the GUI.
	% Last Modified: 11:52 AM Monday, November 23, 2015
	% Modified By: Zhanqiu Liu (lafeir.lew@gmail.com)
	
	if isempty(handles.hdata)
		return
	end
	
	% fieldnames(handles.hdata.seq(ind(1)))
	% ind = ~cellfun(@isempty,{handles.hdata.seq.DENSEdata}); ind = find(ind);
	EncFreq = zeros(0,0); idx = [];
	for ii = 1:numel(handles.hdata.seq)
		try
			if isempty(handles.hdata.seq(ii).DENSEdata.EncFreq);
				EncFreq = [EncFreq NaN];
			else
				EncFreq = [EncFreq handles.hdata.seq(ii).DENSEdata.EncFreq];
				idx = [idx, ii];
			end
		catch
			EncFreq = [EncFreq NaN];
		end
	end
	% DENSE
	if dense
		clear DENSE;
		for ii=1:numel(idx)
			DENSE(ii).SeriesNumber = handles.hdata.seq(idx(ii)).SeriesNumber;
			DENSE(ii).SeriesDescription = handles.hdata.seq(idx(ii)).SeriesDescription;%ProtocolName
			DENSE(ii).EncFreq = handles.hdata.seq(idx(ii)).DENSEdata.EncFreq;
			DENSE(ii).Scale = handles.hdata.seq(idx(ii)).DENSEdata.Scale;
			DENSE(ii).PixelSpacing=handles.hdata.seq(idx(ii)).PixelSpacing;
			DENSE(ii).SliceThickness=handles.hdata.seq(idx(ii)).SliceThickness;
			DENSE(ii).NumberOfAverages=handles.hdata.seq(idx(ii)).NumberOfAverages;
			DENSE(ii).EchoTime=handles.hdata.seq(idx(ii)).EchoTime;
			DENSE(ii).TriggerTime=handles.hdata.seq(idx(ii)).TriggerTime;
			DENSE(ii).RepetitionTime=handles.hdata.seq(idx(ii)).RepetitionTime;
			DENSE(ii).CardiacNumberOfImages=handles.hdata.seq(idx(ii)).CardiacNumberOfImages;
			% DENSE(ii).EchoNumber=handles.hdata.seq(idx(ii)).EchoNumber;
			DENSE(ii).FlipAngle=handles.hdata.seq(idx(ii)).FlipAngle;
			DENSE(ii).AcquisitionMatrix=handles.hdata.seq(idx(ii)).AcquisitionMatrix;
			DENSE(ii).MagneticFieldStrength=handles.hdata.seq(idx(ii)).MagneticFieldStrength;
		end
		openvar DENSE;
		keyboard
	end
	[tmp, ind] = unique(EncFreq);
	ind(isnan(tmp)) = [];
	
	Age = datestr(datenum(handles.hdata.seq(ind(1)).StudyDate,'YYYYmmDD') - datenum(handles.hdata.seq(ind(1)).PatientBirthDate,'YYYYmmDD'),'mmDD');%'YYYYmmDD');

	datenum(handles.hdata.seq(ind(1)).PatientBirthDate,'YYYYmmDD');
	string = {'------Subject Info------',...
	strcat('Sex:', handles.hdata.seq(ind(1)).PatientSex),...
	strcat('BirthDate:', handles.hdata.seq(ind(1)).PatientBirthDate),...
	strcat('StudyDate:', handles.hdata.seq(ind(1)).StudyDate),...
	strcat('Age:', Age),...
	'------Scanning Properties------'};
	
	for ii = reshape(ind,1,[])
		string = {string{:},...
		strcat('------Seq #',num2str(ii),'------'),...
		sprintf('EncFreq:%d', handles.hdata.seq(ii).DENSEdata.EncFreq),...
		sprintf('ImagingFrequency:%d', handles.hdata.seq(ii).ImagingFrequency),...
		sprintf('MagneticFieldStrength:%d', handles.hdata.seq(ii).MagneticFieldStrength),...
		strcat('PixelSpacing:',sprintf('%d', handles.hdata.seq(ii).PixelSpacing)),...
		sprintf('SliceThickness:%d', handles.hdata.seq(ii).SliceThickness),...
		sprintf('RepetitionTime:%d', handles.hdata.seq(ii).RepetitionTime),...
		sprintf('TriggerTime:%d', handles.hdata.seq(ii).TriggerTime),...
		sprintf('EchoTime:%d', handles.hdata.seq(ii).EchoTime),...
		sprintf('CardiacNumberOfImages:%d', handles.hdata.seq(ii).CardiacNumberOfImages)};
		% sprintf('NominalInterval:%d', handles.hdata.seq(ii).NominalInterval),...
		% sprintf('EchoNumber:%d', handles.hdata.seq(ii).EchoNumber),...
		% sprintf('EchoTrainLength:%d', handles.hdata.seq(ii).EchoTrainLength),...
		% sprintf('InversionTime:%d', handles.hdata.seq(ii).InversionTime),...
		% sprintf(':%d', handles.hdata.seq(ii).),...
	end
	
	string{:}
	msgbox(string,'Important DatasetInfo');
	warning('Break here!');
end
