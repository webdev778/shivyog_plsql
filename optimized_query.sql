
	
	-- sy_clubs = SyClub.active_global
	SELECT  "sy_clubs".* FROM "sy_clubs" INNER JOIN "addresses" ON "addresses"."addressable_id" = "sy_clubs"."id" 
	AND "addresses"."deleted_at" IS NULL AND "addresses"."addressable_type" = $1 
	WHERE "sy_clubs"."is_deleted" = $2 AND NOT (("addresses"."country_id" = $3 OR "addresses"."country_id" IS NULL)) 
	AND "sy_clubs"."status" != $4 ORDER BY "sy_clubs"."id" ASC LIMIT $5  
	[["addressable_type", "SyClub"], ["is_deleted", false], ["country_id", 113], ["status", 1], ["LIMIT", 11]]
	
	
	-- main sql statement
	SELECT scb.id FORUM_ID, dcn.NAME COUNTRY, dst.NAME STATE, dct.NAME CITY,  scb.NAME FORUM_NAME, scb.members_count 
-- 	SELECT COUNT(1)
	FROM sy_clubs scb INNER JOIN  addresses adr ON (adr.addressable_id = scb.id  AND adr.addressable_type = 'SyClub' AND adr.deleted_at IS NULL)
	LEFT JOIN db_countries dcn ON (adr.country_id = dcn.id) LEFT JOIN db_states dst ON (adr.state_id = dst.id) LEFT JOIN db_cities dct ON (adr.city_id = dct.id)
	
	WHERE
 	scb.is_deleted = false AND scb."status" != 1 AND
 	NOT ((adr."country_id" = 113 OR adr."country_id" IS NULL))
	
	-- -- get count of members in sy_club
	
	SELECT COUNT(1) FROM sadhak_profiles INNER JOIN sy_club_members ON "sadhak_profiles"."id" = "sy_club_members"."sadhak_profile_id"
	where
	"sadhak_profiles"."deleted_at" IS NULL AND "sy_club_members"."deleted_at" IS NULL 
	AND "sy_club_members"."sy_club_id" = 440 AND "sy_club_members"."status" = 1 AND "sy_club_members"."is_deleted" = false
	AND "sy_club_members"."event_registration_id" IS NOT NULL

/***************************************PRESIDENT INFO ************************************************/
/*****************************************************************************************************/

/* 11 ~ 14, 

PRESIDENT_SYID
PRESIDENT_FULLNAME
PRESIDENT_MOBILE
PRESIDENT_EMAIL

*/

-- SyClubSadhakProfileAssociation Load (0.6ms) 	
-- SELECT  "sy_club_sadhak_profile_associations".* FROM "sy_club_sadhak_profile_associations"
-- WHERE "sy_club_sadhak_profile_associations"."deleted_at" IS NULL AND "sy_club_sadhak_profile_associations"."sy_club_id" = $1
-- 	 [["sy_club_id", 551], ["LIMIT", 11]]
	 
	SELECT spr.syid PRESIDENT_SYID,
			 initcap(concat(spr.first_name, ' ', spr.middle_name, ' ', spr.last_name)) PRESIDENT_FULLNAME,
			 spr.mobile PRESIDENT_MOBILE,
			 spr.email PRESIDENT_EMAIL


   from sy_club_sadhak_profile_associations csp 
	INNER JOIN sadhak_profiles spr ON (csp.sadhak_profile_id = spr.id)
	where 
	csp."deleted_at" IS NULL AND
	csp."sy_club_user_role_id" = 1 AND -- PRESIDENT
	csp."sy_club_id" = 551 -- scb.id 

--	15. photo_id_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No',

-- SadhakProfile Load (0.4ms)  SELECT  "sadhak_profiles".* FROM "sadhak_profiles" WHERE "sadhak_profiles"."deleted_at" IS NULL AND "sadhak_profiles"."id" = $1 LIMIT $2  [["id", 11619], ["LIMIT", 1]]
-- AdvanceProfile Load (7.9ms)  SELECT  "advance_profiles".* FROM "advance_profiles" WHERE "advance_profiles"."deleted_at" IS NULL AND "advance_profiles"."sadhak_profile_id" = $1 LIMIT $2  [["sadhak_profile_id", 11619], ["LIMIT", 1]]
-- Image Load (56.1ms)  SELECT  "images".* FROM "images" WHERE "images"."deleted_at" IS NULL AND "images"."imageable_id" = $1 AND "images"."imageable_type" = $2 LIMIT $3  [["imageable_id", 10314], ["imageable_type", "AdvanceProfilePhotograph"], ["LIMIT", 1]]

	SELECT * FROM sadhak_profiles spr LEFT JOIN advance_profiles apr ON (spr.id = apr.sadhak_profile_id)
	LEFT JOIN images img ON ( img."imageable_id" = apr AND img."imageable_type" = $2 )
	
	WHERE 
	spr."deleted_at" IS NULL AND
	apr."deleted_at" IS NULL AND
	img."deleted_at" IS NULL AND
	
	
	
	
	
	
