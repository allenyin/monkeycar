% COMPRESS_FILE compress a data file
%
% $Id$
%
% fn        - filename to operate upon
% compfn    - compressed filename
% status    - 0 on success; nonzero on error

function [compfn, status] = compress_file(fn)

    % correct these, as needed
    if (ispc)
        GZIP = 'c:\cygwin\bin\gzip';
        BZIP2 = 'c:\cygwin\usr\bin\bzip2';
        ZIP = 'c:\cygwin\usr\bin\zip';
    else
        GZIP = '/bin/gzip';
        BZIP2 = '/usr/bin/bzip2';
        ZIP = '/usr/bin/zip';
    end

    % UNCOMMENT ONE OF THESE LINES
    COMPRESS = GZIP; EXT = '.gz';
    % COMPRESS = BZIP2; EXT = '.bz2';
    % COMPRESS = ZIP; EXT = '.zip';

    compfn = [fn EXT];
    [pathstr,filestr,ext] = fileparts(fn);
    clear pathstr;

    if (exist(fn,'file') ~= 2)
        disp([filestr ext ' does not exist! ABORTING!']);
        status = -1;
        return;
    end
    if (exist(compfn,'file') == 2)
        disp([compfn ' already exists! ABORTING!']);
        status = -1;
        return;
    end
    
    disp(['compressing ' filestr ext]);
    [status] = system([COMPRESS ' "' fn '"']);