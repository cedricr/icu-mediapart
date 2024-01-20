
# Sources :

**ADMIN EXPRESS** 3.2, édition juin 2023 (par territoire, France Métropolitaine) de l'IGN, pour les contours de communes, des EPCI, et des arrondissements. 
https://geoservices.ign.fr/adminexpress#telechargement

**BD TOPO** 3.3, édition juin 2023 (SQL France entière) de l'IGN, pour la végétation, les routes et l'hydrographie.
https://geoservices.ign.fr/bdtopo#telechargementsqlfra


**Quartiers prioritaires de la politique de la ville**, version shp, de l'ANCT.
https://sig.ville.gouv.fr/atlas/QP
ou
https://www.data.gouv.fr/fr/datasets/quartiers-prioritaires-de-la-politique-de-la-ville-qpv/


**Données carroyées Filosofi** 2017 de l'INSEE, au carreau de 200m, format géopackage.
https://www.insee.fr/fr/statistiques/6215168?sommaire=6215217

**Données Landsat-8 et Landsat-9**,  U.S. Geological Survey
https://earthexplorer.usgs.gov

Ces données doivent être téléchargées dans le repertoire data, avec la structure suivante.
```
data:
Admin_Express_3.2/  Filosofi2017_carreaux_200m_met.gpkg  Landsat/  QPV/

data/Admin_Express_3.2:
ARRONDISSEMENT.cpg  ARRONDISSEMENT.shp  COMMUNE.dbf  COMMUNE.shx  EPCI.prj
ARRONDISSEMENT.dbf  ARRONDISSEMENT.shx  COMMUNE.prj  EPCI.cpg     EPCI.shp
ARRONDISSEMENT.prj  COMMUNE.cpg         COMMUNE.shp  EPCI.dbf     EPCI.shx

data/Landsat:
LC08_L2SP_199025_20220813_20220824_02_T1.tar LC09_L2SP_196030_20220715_20220719_02_T1.tar
LC08_L2SP_199026_20220813_20220824_02_T1.tar

data/QPV:
QP_METROPOLE_LB93.dbf  QP_METROPOLE_LB93.prj  QP_METROPOLE_LB93.shp  QP_METROPOLE_LB93.shx

```
