%% SPKWAV_TRANS: Translate spkwav file using plx2mat output, new filename, and translation file
% spkwav_trans(fin,fout,ftrans);
% spkwav_trans(fin,fout,ftrans,mode);
%   fin - input filename (*_spkwav.mat, output of plx2mat)
%   fout - output filename
%   ftrans - translation file, gives channel conversion from sig### to other prefix
%   mode (optional) - 0 (DEFAULT): timestamps & waveform info, 1: timestamps only
%
% *** Translation file should be configured as follows (example):
% % CH_LO   CH_HI   PREFIX
% 1 32 RHA1
% 33 64 RHA3
% 65 96 RHL2
% 97 128 RHL3
%
% NOTE: All sig### channels that don't match are removed
function spkwav_trans(fin, fout, ftrans, varargin)
    % Set mode
    if (numel(varargin)>0)
        mode = varargin{1};
    else
        mode = 0;
    end
    % If translation file is missing, just copy file, removing waveform
    % info if desired
    if (~exist(ftrans,'file'))
        if (mode==0) % All data
            copyfile(fin,fout);
        else    % Timestamps only
            try
                load(fin);
            catch
                error(['FILE ' fin ' could not be loaded!!!']);
            end
            % Same output filename in metadata
            metadata.transfname = fout;
            % Now, clear messy variables
            clear fin fout ftrans mode varargin;
            % Clear non-timestamp data
            clear -regexp '^.*\d\d\d[abcdi]_.*$';
            % Save now
            save(metadata.transfname);
            return;
        end
    end
    % Otherwise, load translation file
    [rawData{1:3}]=textread(ftrans,'%d%d%s','commentstyle','matlab');
    chanTable = [rawData{1} rawData{2}];
    prefixAry = rawData{3};
    nEntry = numel(prefixAry);
    clear rawData;
    % Load input file into workspace
    try
        load(fin);
    catch
        error(['FILE ' fin ' could not be loaded!!!']);
    end
    % Get a list of all sig variables
    S = who('sig*');
    for i=1:numel(S),
        % Parse varname
        varname = regexp(S{i},'sig(?<chan>\d\d\d)(?<suffix>.*)','names');
        varname.chan = str2num(varname.chan);
        % If mode=1, delete this variable if it is not just a timestamp variable
        if (mode==1 && isempty(regexp(varname.suffix,'^[abcdi]$')))
            eval(['clear ' S{i}]);
        else
            % Otherwise, translate the name to the new format
            good = 0;
            for j=1:nEntry,
                if ((varname.chan>=chanTable(j,1)) && (varname.chan<=chanTable(j,2)))
                    newchan = varname.chan - (chanTable(j,1)-1);
                    newname = sprintf('%s%03d%s',prefixAry{j},newchan,varname.suffix);
                    good = 1;
                    break;
                end
            end
            % Only rename if translation has occurred
            if (good)
                eval([newname ' = ' S{i} ';']);
            else
                % Otherwise give warning
                warning(['No translation found for ' S{i} '!!! (will be deleted)']);
            end
            % Now delete original
            eval(['clear ' S{i}]);
        end
    end 
    % Same output filename in metadata
    metadata.transfname = fout;
    % Now, clear messy variables
    clear S chanTable fin fout ftrans good i j mode nEntry newchan newname prefixAry varargin varname;
    % Finally, save output data
    save(metadata.transfname);
end