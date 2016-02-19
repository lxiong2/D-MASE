for a = 1:8
    [tempnotContig,tempcontigDistance,tempparent] = checkContig(a,onlybuses{a},innerlines{a});
    overallContig{a} = tempnotContig;
    overallDistance{a} = tempcontigDistance;
    overallParent{a} = tempparent;
end