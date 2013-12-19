% DECOMPRESS_FILE compress a data file
%
% $Id$
%
% fn        - filename to operate upon
% dcfn      - decompressed filename
% status    - 0 on success; nonzero on error

function [dcfn, status] = decompress_file(fn)

    % correct these, as needed
    if (ispc)
        GZIP = 'c:\cygwin\bin\gzip -d';
        BZIP2 = 'c:\cygwin\usr\bin\bzip2 -d';
        ZIP = 'c:\cygwin\usr\bin\unzip';
    else
        GZIP = '/bin/gzip -d';
        BZIP2 = '/usr/bin/bzip2 -d';
        ZIP = '/usr/bin/unzip';
    end
    
    [pathstr,filestr,ext] = fileparts(fn);
    dcfn = fullfile(pathstr,filestr);

    if (exist(fn,'file') ~= 2)
        disp([filestr ext ' does not exist! ABORTING!']);
        status = -1;
        return;
    end

    % what sort of file are we dealing with
    if (strcmp(ext,'.gz')) 
        DECOMPRESS = GZIP;
    elseif (strcmp(ext,'.bz2')) 
        DECOMPRESS = BZIP2;
    elseif (strcmp(ext,'.zip')) 
        DECOMPRESS = ZIP;
    else
        disp([filestr ext ' has unknown compression! ABORTING!']);
        status = -2;
        return;
    end

    disp(['decompressing ' filestr ext]);
    [status result] = system([DECOMPRESS ' "' fn '"']);
