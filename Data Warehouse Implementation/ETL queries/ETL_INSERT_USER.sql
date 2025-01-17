USE CarSharingDW
GO

CREATE TABLE #temp_user("user_id" INT IDENTITY(1, 1), gender VARCHAR(6), age VARCHAR(6))
INSERT INTO #temp_user
SELECT gender,
CASE
    WHEN age <= 25 THEN '18-25'
    WHEN age > 25 AND age <= 33 THEN '26-33'
    WHEN age > 33 AND age <= 41 THEN '34-41'
    WHEN age > 41 AND age <= 49 THEN '42-49'
    WHEN age > 49 AND age <= 57 THEN '50-57'
    WHEN age > 57 THEN '58+'
END AS age
FROM CarSharing.dbo.USERS

SET IDENTITY_INSERT #temp_user ON;
GO
INSERT INTO #temp_user("user_id", gender, age)
VALUES (-1, NULL, NULL)
GO

MERGE INTO "USER" as TT
	USING #temp_user as ST
		ON TT."user_id" = ST."user_id"
		--AND TT.gender = ST.gender
		--AND TT.age = ST.age
		WHEN NOT MATCHED THEN
			INSERT VALUES (ST."user_id", ST.gender, ST.age)
		WHEN NOT MATCHED BY Source THEN
			DELETE;

DROP TABLE #temp_user