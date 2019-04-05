function unprocessedarg=parsearg(pconfig,varargin)
% PARSEARG Parse the input arguments according to pconfig
%   by Ang Kai Keng (kkang@i2r.a-star.edu.sg)
%
%   Syntax:
%     parsearg(pconfig,varargin{:})
%     p=parsearg(pconfig,varargin{:})
%
%   where
%     pconfig: argument configurations for parsearg where
%       pconfig.opt{:}={name,defaultvalue,hvalidatorfunc} 
%       pconfig.para{:}={name,defaultvalue,hvalidatorfunc)
%
%   Description:
%       All arguments are stored as structs of the output of parsearg 
%       using the name of the argument in pconfig. If output of parsearg is 
%       not specified, the parameters are stored in the caller function 
%       workspace.
%
%       opt specifies optional arguments, and para specifies parameters.
%       defaultvalue is assigned to the agument if value is not specified.
%       hvalidatorfunc is the handle to the validator function that is used 
%         to validate the arguments.
%
%   Example:
%       pconfig.opt{1}={'W', [], @(x)(isnumeric(x) && ~isscalar(x))};
%       pconfig.opt{2}={'m', 3, @isnumeric};
%       pconfig.para{1}={'showwaitbar', 0, @isnumeric};
%       parsearg(pconfig,varargin{:})
%       
%   See also INPUTPARSER.

unprocessedarg={};
if isfield(pconfig,'opt')
    noptarg=length(pconfig.opt);
else
    noptarg=0;
end
if isfield(pconfig,'para')
    nparaarg=length(pconfig.para);
else
    nparaarg=0;
end

for i=1:noptarg
    if isempty(varargin)
        tempopt=pconfig.opt{i};
        assignin('caller',tempopt{1},tempopt{2});
    else
        tempopt=pconfig.opt{i};
        optfun=tempopt{3};
        if isempty(optfun) || optfun(varargin{1})
            assignin('caller',tempopt{1},varargin{1});
            varargin(1)=[];
        else
            assignin('caller',tempopt{1},tempopt{2});
        end
    end
end
for i=1:nparaarg
    temppara=pconfig.para{i};
    assignin('caller',temppara{1},temppara{2});
end
while ~isempty(varargin) && nparaarg>0
    if ischar(varargin{1})
        paranotfound=true;
        for i=1:nparaarg
            temppara=pconfig.para{i};
            if strcmpi(varargin{1},temppara{1})
                paranotfound=false;
                optfun=temppara{3};
                if isempty(optfun) || optfun(varargin{2})
                    assignin('caller',temppara{1},varargin{2});
                end
                varargin(1)=[];
                varargin(1)=[];
                break
            end
        end
        if paranotfound
            %printf(['Parameter ' varargin{1} ' not recognized.']);
            unprocessedarg={unprocessedarg{:},varargin{1}};
            varargin(1)=[];
            unprocessedarg={unprocessedarg{:},varargin{1}};
            varargin(1)=[];
        end
    else
        %warning('Unknown parameter type. Ignored:'); %#ok<WNTAG>
		fprintf('Unknown parameter type. Ignored:'); %#ok<WNTAG>
        %dbstop in parsearg at 89;
        varargin(1)=[];
    end
end