function [newnode, newelem, newelem0] = surfboolean(node, elem, varargin)
%
% [newnode,newelem,newelem0]=surfboolean(node1,elem1,op2,node2,elem2,op3,node3,elem3,...)
%
% merge two or more triangular meshes and resolve intersecting elements
%
% author: Qianqian Fang <q.fang at neu.edu>
%
% input:
%      node: node coordinates, dimension (nn,3)
%      elem: triangle surfaces (ne,3)
%      op:  a string of a boolean operator, possible op values include
%           'union' or 'or': the outter surface of the union of the enclosed space
%           'inter' or 'and': the surface of the domain contained by both meshes
%           'diff' or '-': the surface of the domain in mesh 1 excluding that of
%                   mesh 2
%           'all', 'resolve', or 'xor' or '+': the output contains 4 subsurfaces, identified by the 4th
%                  column of newelem:
%                    1: mesh 1 outside of mesh 2
%                    2: mesh 2 outside of mesh 1
%                    3: mesh 1 inside of mesh 2
%                    4: mesh 2 inside of mesh 1
%                  you can use newelem(find(mod(newelem(:,4),2)==1),:) to
%                  get mesh 1 cut by mesh 2, or newelem(find(mod(newelem(:,4),2)==0),:)
%                  to get mesh 2 cut by mesh 1;
%           'first': combine 1 and 3 from the output of 'all'
%           'second': combine 2 and 4 from the output of 'all'
%           'self': test for self-intersections; only the first mesh is
%                   tested; other inputs are ignored.
%           'remesh': remesh the first input mesh (2nd input mesh is ignored)
%           'decouple': separate two shells and make sure there is no intersection;
%                   the input surfaces must be closed and ordered from outer to inner
%
%           if a dash '-' is preceding a command, including
%              -diff, -union, -isct, -resolve, -first, -second, -xor
%           a 'remesh' operation is applied to the output mesh to remove poorly shaped
%           triangles
%
% output:
%      newnode: the node coordinates after boolean operations, dimension (nn,3)
%      newelem: tetrahedral element or surfaces after boolean operations (nn,4) or (nhn,5)
%      newelem0: when the operator is 'self', return the intersecting
%               element list in terms of the input node list (experimental)
%
% example:
%
%   [node1,face1,elem1]=meshabox([0 0 0],[10 10 10],1,1);
%   [node2,face2,elem2]=meshabox([0 0 0]+5,[10 10 10]+5,1,1);
%   [newnode,newface]=surfboolean(node1,face1,'union',node2,face2);
%   plotmesh(newnode,newface);
%   [newnode,newface]=surfboolean(node1,face1,'-union',node2,face2);
%   figure; plotmesh(newnode,newface);
%   [newnode,newface]=surfboolean(node1,face1,'diff',node2,face2);
%   figure;plotmesh(newnode,newface,'x>5');
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

len = length(varargin);
newnode = node;
newelem = elem;
if (len > 0 && mod(len, 3) ~= 0)
    error('you must give operator, node and element in a triplet form');
end

try
    exename = evalin('caller', 'ISO2MESH_SURFBOOLEAN');
catch
    try
        exename = evalin('base', 'ISO2MESH_SURFBOOLEAN');
    catch
        exename = 'cork';
    end
end

exesuff = fallbackexeext(getexeext, exename);
randseed = hex2dec('623F9A9E'); % "U+623F U+9A9E"
if (~isempty(getvarfrom({'caller', 'base'}, 'ISO2MESH_RANDSEED')))
    randseed = getvarfrom({'caller', 'base'}, 'ISO2MESH_RANDSEED');
end

for i = 1:3:len
    op = varargin{i};
    no = varargin{i + 1};
    el = varargin{i + 2};
    opstr = op;
    if (strcmp(op, 'or'))
        opstr = 'union';
    end
    if (strcmp(op, 'xor'))
        opstr = 'all';
    end
    if (strcmp(op, 'and'))
        opstr = 'isct';
    end
    if (strcmp(op, '-'))
        opstr = 'diff';
    end
    if (strcmp(op, 'self'))
        opstr = 'solid';
    end
    if (strcmp(opstr, 'all'))
        opstr = 'resolve';
    end
    tempsuff = 'off';
    deletemeshfile(mwpath(['pre_surfbool*.' tempsuff]));
    deletemeshfile(mwpath('post_surfbool.off'));
    if (strcmp(opstr, 'all'))
        deletemeshfile(mwpath('s1out2.off'));
        deletemeshfile(mwpath('s1in2.off'));
        deletemeshfile(mwpath('s2out1.off'));
        deletemeshfile(mwpath('s2in1.off'));
    end
    if (strcmp(op, 'decouple'))
        if (exist('node1', 'var') == 0)
            node1 = node;
            elem1 = elem;
            newnode(:, 4) = 1;
            newelem(:, 4) = 1;
        end
        opstr = ' --decouple-inin 1 --shells 2'; % -q
        saveoff(node1(:, 1:3), elem1(:, 1:3), mwpath('pre_decouple1.off'));
        if (size(no, 2) ~= 3)
            opstr = ['-q --shells ' num2str(no)];
            cmd = sprintf('cd "%s" && "%s%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), opstr);
        else
            saveoff(no(:, 1:3), el(:, 1:3), mwpath('pre_decouple2.off'));
            cmd = sprintf('cd "%s" && "%s%s" "%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), mwpath('pre_decouple2.off'), opstr);
        end
    elseif (strcmp(op, 'decoupleout'))
        if (exist('node1', 'var') == 0)
            node1 = node;
            elem1 = elem;
            newnode(:, 4) = 1;
            newelem(:, 4) = 1;
        end
        opstr = [' --decouple-outout 1 --shells 2']; % -q
        saveoff(node1(:, 1:3), elem1(:, 1:3), mwpath('pre_decouple1.off'));
        if (size(no, 2) ~= 3)
            opstr = ['-q --shells ' num2str(no)];
            cmd = sprintf('cd "%s" && "%s%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), opstr);
        else
            saveoff(no(:, 1:3), el(:, 1:3), mwpath('pre_decouple2.off'));
            cmd = sprintf('cd "%s" && "%s%s" "%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), mwpath('pre_decouple2.off'), opstr);
        end
    elseif (strcmp(op, 'separate'))
        if (exist('node1', 'var') == 0)
            node1 = node;
            elem1 = elem;
            newnode(:, 4) = 1;
            newelem(:, 4) = 1;
        end
        opstr = ' --shells 2'; % -q
        saveoff(node1(:, 1:3), elem1(:, 1:3), mwpath('pre_decouple1.off'));
        if (size(no, 2) ~= 3)
            opstr = ['-q --shells ' num2str(no)];
            cmd = sprintf('cd "%s" && "%s%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), opstr);
        else
            saveoff(no(:, 1:3), el(:, 1:3), mwpath('pre_decouple2.off'));
            cmd = sprintf('cd "%s" && "%s%s" "%s" "%s" %s', mwpath, mcpath('meshfix'), exesuff, ...
                          mwpath('pre_decouple1.off'), mwpath('pre_decouple2.off'), opstr);
        end
    elseif (strcmp(op, 'remesh'))
        saveoff(newnode(:, 1:3), newelem(:, 1:3), mwpath(['pre_surfbool1.' tempsuff]));
        cmd = sprintf('cd "%s" && "%s%s" %s%s "%s" "%s" -%d', mwpath, mcpath(exename), exesuff, '-', ...
                      opstr, mwpath(['pre_surfbool1.' tempsuff]), mwpath('post_surfbool.off'), randseed);
    else
        saveoff(newnode(:, 1:3), newelem(:, 1:3), mwpath(['pre_surfbool1.' tempsuff]));
        saveoff(no(:, 1:3), el(:, 1:3), mwpath(['pre_surfbool2.' tempsuff]));
        cmd = sprintf('cd "%s" && "%s%s" %s%s "%s" "%s" "%s" -%d', mwpath, mcpath(exename), exesuff, '-', ...
                      opstr, mwpath(['pre_surfbool1.' tempsuff]), mwpath(['pre_surfbool2.' tempsuff]), mwpath('post_surfbool.off'), randseed);
    end
    [status, outstr] = system(cmd);
    if (status ~= 0 && strcmp(op, 'self') == 0)
        error('surface boolean command failed:\n%s\nERROR: %s\n', cmd, outstr);
    end
    if (strcmp(op, 'self'))
        if (isempty(strfind(outstr, 'NOT SOLID')))
            fprintf(1, 'no self-intersection was found!\n');
            newnode = [];
            newelem = [];
            newelem0 = [];
        else
            fprintf(1, 'input mesh is self-intersecting\n');
            newnode = 1;
            newelem = [];
            newelem0 = 1;
        end
        return
    end
    if (strcmp(opstr, 'all'))
        % tag the 4 piceses of meshes, this tag do not propagate to the next boolean operation
        [nnode, nelem] = readoff(mwpath('s1out2.off'));
        newelem = [nelem ones(size(nelem, 1), 1)];
        newnode = [nnode ones(size(nnode, 1), 1)];

        [nnode, nelem] = readoff(mwpath('s1in2.off'));
        newelem = [newelem; nelem + size(newnode, 1) 3 * ones(size(nelem, 1), 1)];
        newnode = [newnode; nnode 3 * ones(size(nnode, 1), 1)];

        [nnode, nelem] = readoff(mwpath('s2out1.off'));
        newelem = [newelem; nelem + size(newnode, 1) 2 * ones(size(nelem, 1), 1)];
        newnode = [newnode; nnode 2 * ones(size(nnode, 1), 1)];

        [nnode, nelem] = readoff(mwpath('s2in1.off'));
        newelem = [newelem; nelem + size(newnode, 1) 4 * ones(size(nelem, 1), 1)];
        newnode = [newnode; nnode 4 * ones(size(nnode, 1), 1)];
    elseif (strcmp(op, 'decouple'))
        [newnode, newelem] = readoff(mwpath('pre_decouple1_fixed.off')); % [node1,elem1]
        % newelem=[newelem;elem1+size(newnode,1) (i+1)*ones(size(elem1,1),1)];
        % newnode=[newnode;node1 (i+1)*ones(size(node1,1),1)];
    elseif (strcmp(op, 'separate'))
        [newnode, newelem] = readoff(mwpath('pre_decouple1_fixed.off'));
    elseif (strcmp(op, 'decoupleout'))
        [newnode, newelem] = readoff(mwpath('pre_decouple1_fixed.off')); % [node1,elem1]
    else
        [newnode, newelem] = readoff(mwpath('post_surfbool.off'));
        if (strcmp(op, 'self'))
            fprintf(1, 'a total of %d self-intersecting elements were found\n', size(newelem, 1));
            if (nargout >= 3)
                [found, newelem0] = ismember(newnode, node, 'rows');
                if (~all(found))
                    error('self intersecting elements contain new nodes');
                end
                newelem0 = newelem0(newelem);
            end
            return
        end
    end
end
