Project I  D: 2023-B00009-001
Project Name: 전립선암 환자의 약물 사용 현황 및 이상사례 실태조사
Project Goal: Androgen deprivation therapy(ADT) 환자에서의 치매 및 파킨슨병 발생 위험을 비 ADT군과 비교

발  주  처: 한국의약품안전관리원
연구책임자: 아주대 이한길 교수
공동연구자: 서울대 정창욱 교수
실  무  자: 서울대학교병원 김수현 (02-2072-4864, 5d932@snuh.org)


Version 2: 2023년 12월 14일 배포
Update: 에러 및 sqlrender 기반으로 코드 수정


1. Open AdtVsNonadt.proj

2. Run 6 R scripts
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_1_Setting.R
    >>> Put # 2. DB information
    
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_2_CreateCohortTables.R
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_3_CreateCohortSets.R
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_4_CreateCovariateSets.R
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_5_Analysis.R
    - AdtVsNonadt/MOA_CDM_PC_ADT_code_6_SubgroupAnalysis.R
    >>> Put # INPUT PARAMETERS

3. Post outputFolder.zip