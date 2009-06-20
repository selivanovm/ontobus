DROP TABLE IF EXISTS TRIPLETS;
CREATE TABLE TRIPLETS (ID BIGINT AUTO_INCREMENT PRIMARY KEY, SUBJ VARCHAR(255), OBJ TEXT(10000), PRED VARCHAR(255), MODIFIER INT(3));
CREATE INDEX PRED_IDX ON TRIPLETS(PRED);
CREATE INDEX SUBJ_IDX ON TRIPLETS(SUBJ);
CREATE INDEX OBJ_IDX ON TRIPLETS(OBJ);
CREATE INDEX SOP_IDX ON TRIPLETS(SUBJ, OBJ, PRED);