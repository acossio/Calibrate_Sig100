function [] = f_assignin_allvars()

myVarList=who;
for indVar = 1:length(myVarList)
    %assignin('base',myVarList{indVar},eval(myVarList{indVar}))
    assignin('caller',myVarList{indVar},eval(myVarList{indVar}))
end