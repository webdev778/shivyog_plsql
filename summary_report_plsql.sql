DROP FUNCTION forum_summary_report ();

CREATE OR REPLACE FUNCTION public.forum_summary_report ()
    RETURNS TABLE (
		FORUM_ID 									SY_CLUBS.id%TYPE,
		COUNTRY 									db_countries.name % TYPE,
		STATE 										db_STATES.name % TYPE,
		CITY 										db_CITIES.name % TYPE,
		ADDRESS 									addresses.first_line%TYPE,
		FORUM_NAME 								    SY_CLUBS.name%TYPE,
		MEMBERS_COUNT                                                         INT,
		CREATED_AT                                                            SY_CLUBS.CREATED_AT%TYPE,
		UPDATED_AT                                                            SY_CLUBS.UPDATED_AT%TYPE,
		PRESIDENT_SYID                                                        sadhak_profiles.SYID%TYPE,
		PRESIDENT_FULLNAME                                                    sadhak_profiles.FIRST_NAME%TYPE,
		PRESIDENT_MOBILE                                                      sadhak_profiles.mobile%TYPE,
		PRESIDENT_EMAIL                                                       sadhak_profiles.email%TYPE,
		PRESIDENT_PHOTO_ID_UPLOADED                                           VARCHAR(10),
		PRESIDENT_PHOTO_ID_APPROVED                                           VARCHAR(10),
		PRESIDENT_PHOTO_ID_PROOF_UPLOADED                                     VARCHAR(10),
		PRESIDENT_PHOTO_ID_PROOF_APPROVED                                     VARCHAR(10),
		PRESIDENT_PHOTO_ID_PROOF_NUMBER                                       advance_profiles.photo_id_proof_number%TYPE,
		PRESIDENT_ADDRESS_PROOF_UPLOADED                                      VARCHAR(10),
		PRESIDENT_ADDRESS_PROOF_APPROVED                                      VARCHAR(10),
		PRESIDENT_PHOTO_ID_LAST_UPDATED                                       IMAGES.UPDATED_AT%TYPE,
		PRESIDENT_PHOTO_ID_PROOF_LAST_UPDATED                                 IMAGES.UPDATED_AT%TYPE,
		IS_PRESIDENT_FORUM_MEMBER                                             boolean,
		PRESIDENT_PAYMENT_DATE                                                VARCHAR,
		PRESIDENT_EXPIRATION_DATE                                             VARCHAR,
		IS_PRESIDENT_RENEWED                                                  boolean,
		PRESIDENT_MEMBERSHIP_STATUS                                           VARCHAR(10),

		VICE_PRESIDENT_1_SYID                                                        sadhak_profiles.SYID%TYPE,
		VICE_PRESIDENT_1_FULLNAME                                                    sadhak_profiles.FIRST_NAME%TYPE,
		VICE_PRESIDENT_1_MOBILE                                                      sadhak_profiles.mobile%TYPE,
		VICE_PRESIDENT_1_EMAIL                                                       sadhak_profiles.email%TYPE,
		VICE_PRESIDENT_1_PHOTO_ID_UPLOADED                                           VARCHAR(10),
		VICE_PRESIDENT_1_PHOTO_ID_APPROVED                                           VARCHAR(10),
		VICE_PRESIDENT_1_PHOTO_ID_PROOF_UPLOADED                                     VARCHAR(10),
		VICE_PRESIDENT_1_PHOTO_ID_PROOF_APPROVED                                     VARCHAR(10),
		VICE_PRESIDENT_1_PHOTO_ID_PROOF_NUMBER                                       advance_profiles.photo_id_proof_number%TYPE,
		VICE_PRESIDENT_1_ADDRESS_PROOF_UPLOADED                                      VARCHAR(10),
		VICE_PRESIDENT_1_ADDRESS_PROOF_APPROVED                                      VARCHAR(10),
		VICE_PRESIDENT_1_PHOTO_ID_LAST_UPDATED                                       IMAGES.UPDATED_AT%TYPE,
		VICE_PRESIDENT_1_PHOTO_ID_PROOF_LAST_UPDATED                                 IMAGES.UPDATED_AT%TYPE,
		IS_VICE_PRESIDENT_1_FORUM_MEMBER                                             boolean,
		VICE_PRESIDENT_1_PAYMENT_DATE                                                VARCHAR,
		VICE_PRESIDENT_1_EXPIRATION_DATE                                             VARCHAR,
		IS_VICE_PRESIDENT_1_RENEWED                                                  boolean,
		VICE_PRESIDENT_1_MEMBERSHIP_STATUS                                           VARCHAR(10),
		
		VICE_PRESIDENT_2_SYID                                                        sadhak_profiles.SYID%TYPE,
		VICE_PRESIDENT_2_FULLNAME                                                    sadhak_profiles.FIRST_NAME%TYPE,
		VICE_PRESIDENT_2_MOBILE                                                      sadhak_profiles.mobile%TYPE,
		VICE_PRESIDENT_2_EMAIL                                                       sadhak_profiles.email%TYPE,
		VICE_PRESIDENT_2_PHOTO_ID_UPLOADED                                           VARCHAR(10),
		VICE_PRESIDENT_2_PHOTO_ID_APPROVED                                           VARCHAR(10),
		VICE_PRESIDENT_2_PHOTO_ID_PROOF_UPLOADED                                     VARCHAR(10),
		VICE_PRESIDENT_2_PHOTO_ID_PROOF_APPROVED                                     VARCHAR(10),
		VICE_PRESIDENT_2_PHOTO_ID_PROOF_NUMBER                                       advance_profiles.photo_id_proof_number%TYPE,
		VICE_PRESIDENT_2_ADDRESS_PROOF_UPLOADED                                      VARCHAR(10),
		VICE_PRESIDENT_2_ADDRESS_PROOF_APPROVED                                      VARCHAR(10),
		VICE_PRESIDENT_2_PHOTO_ID_LAST_UPDATED                                       IMAGES.UPDATED_AT%TYPE,
		VICE_PRESIDENT_2_PHOTO_ID_PROOF_LAST_UPDATED                                 IMAGES.UPDATED_AT%TYPE,
		IS_VICE_PRESIDENT_2_FORUM_MEMBER                                             boolean,
		VICE_PRESIDENT_2_PAYMENT_DATE                                                VARCHAR,
		VICE_PRESIDENT_2_EXPIRATION_DATE                                             VARCHAR,
		IS_VICE_PRESIDENT_2_RENEWED                                                  boolean,
		VICE_PRESIDENT_2_MEMBERSHIP_STATUS                                           VARCHAR(10)
  ) AS $$
DECLARE
    v_club_rec record;
BEGIN
    FOR v_club_rec IN (
        SELECT
            scb.id FORUM_ID,
            dcn.NAME COUNTRY,
            dst.NAME STATE,
            dct.NAME CITY,
            concat(adr.first_line, ' ', adr.second_line, ' ', dct.NAME, ' ', dst.NAME, ' ', dcn.NAME, ' ', adr.postal_code) ADDRESS,
            scb.NAME FORUM_NAME,
            scb.created_at CREATED_AT,
            scb.updated_at UPDATED_AT
        FROM
            sy_clubs scb
            INNER JOIN addresses adr ON (adr.addressable_id = scb.id
                    AND adr.addressable_type = 'SyClub'
                    AND adr.deleted_at IS NULL)
            LEFT JOIN db_countries dcn ON (adr.country_id = dcn.id)
            LEFT JOIN db_states dst ON (adr.state_id = dst.id)
            LEFT JOIN db_cities dct ON (adr.city_id = dct.id)
        WHERE
            scb.is_deleted = FALSE
            AND scb. "status" != 1
            AND NOT ((adr. "country_id" = 113
                    OR adr. "country_id" IS NULL)))
        LOOP
			DECLARE
				v_president_id sadhak_profiles.id % TYPE := NULL;   
				v_president_aid advance_profiles.id % TYPE := NULL;
				temp images.id % TYPE := NULL;
				v_temp sadhak_profiles.id % TYPE := NULL;
				v_member_rec record := NULL;			
			BEGIN
				/* ------------------ SY_CLUB INFORMATION -------------------------------- */
				FORUM_ID := v_club_rec.FORUM_ID;
				COUNTRY := v_club_rec.COUNTRY;
				STATE := v_club_rec.STATE;
				CITY := v_club_rec.CITY;
				ADDRESS := v_club_rec.ADDRESS;
				FORUM_NAME := v_club_rec.FORUM_NAME;
				CREATED_AT := v_club_rec.CREATED_AT;
				UPDATED_AT := v_club_rec.UPDATED_AT;

				SELECT 
					COUNT(1) INTO MEMBERS_COUNT
				FROM
					sadhak_profiles spr
					INNER JOIN sy_club_members scm ON spr. "id" = scm. "sadhak_profile_id"
				WHERE
					spr. "deleted_at" IS NULL
					AND spr. "deleted_at" IS NULL
					AND scm. "sy_club_id" = v_club_rec.FORUM_ID
					AND scm. "status" = 1
					AND scm. "is_deleted" = FALSE
					AND scm. "event_registration_id" IS NOT NULL;
			
				/* ------------------ PRESIDENT INFORMATION -------------------------------- */
				SELECT * FROM role_report(FORUM_ID, 1) INTO 
							    PRESIDENT_SYID, 
								PRESIDENT_FULLNAME, 
								PRESIDENT_MOBILE, 
								PRESIDENT_EMAIL, 
								PRESIDENT_PHOTO_ID_UPLOADED, 
								PRESIDENT_PHOTO_ID_APPROVED, 
								PRESIDENT_PHOTO_ID_PROOF_UPLOADED, 
								PRESIDENT_PHOTO_ID_PROOF_APPROVED, 
								PRESIDENT_PHOTO_ID_PROOF_NUMBER,   
								PRESIDENT_ADDRESS_PROOF_UPLOADED,  
								PRESIDENT_ADDRESS_PROOF_APPROVED,  
								PRESIDENT_PHOTO_ID_LAST_UPDATED,   
								PRESIDENT_PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_PRESIDENT_FORUM_MEMBER, 
								PRESIDENT_PAYMENT_DATE, 
								PRESIDENT_EXPIRATION_DATE, 
								IS_PRESIDENT_RENEWED,                  
								PRESIDENT_MEMBERSHIP_STATUS;
				SELECT * FROM role_report(FORUM_ID, 2) INTO
							    VICE_PRESIDENT_1_SYID, 
								VICE_PRESIDENT_1_FULLNAME, 
								VICE_PRESIDENT_1_MOBILE, 
								VICE_PRESIDENT_1_EMAIL, 
								VICE_PRESIDENT_1_PHOTO_ID_UPLOADED, 
								VICE_PRESIDENT_1_PHOTO_ID_APPROVED, 
								VICE_PRESIDENT_1_PHOTO_ID_PROOF_UPLOADED, 
								VICE_PRESIDENT_1_PHOTO_ID_PROOF_APPROVED, 
								VICE_PRESIDENT_1_PHOTO_ID_PROOF_NUMBER,   
								VICE_PRESIDENT_1_ADDRESS_PROOF_UPLOADED,  
								VICE_PRESIDENT_1_ADDRESS_PROOF_APPROVED,  
								VICE_PRESIDENT_1_PHOTO_ID_LAST_UPDATED,   
								VICE_PRESIDENT_1_PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_VICE_PRESIDENT_1_FORUM_MEMBER, 
								VICE_PRESIDENT_1_PAYMENT_DATE, 
								VICE_PRESIDENT_1_EXPIRATION_DATE, 
								IS_VICE_PRESIDENT_1_RENEWED,                  
								VICE_PRESIDENT_1_MEMBERSHIP_STATUS ;
				SELECT * FROM role_report(FORUM_ID, 3) INTO
						       	VICE_PRESIDENT_2_SYID, 
								VICE_PRESIDENT_2_FULLNAME, 
								VICE_PRESIDENT_2_MOBILE, 
								VICE_PRESIDENT_2_EMAIL, 
								VICE_PRESIDENT_2_PHOTO_ID_UPLOADED, 
								VICE_PRESIDENT_2_PHOTO_ID_APPROVED, 
								VICE_PRESIDENT_2_PHOTO_ID_PROOF_UPLOADED, 
								VICE_PRESIDENT_2_PHOTO_ID_PROOF_APPROVED, 
								VICE_PRESIDENT_2_PHOTO_ID_PROOF_NUMBER,   
								VICE_PRESIDENT_2_ADDRESS_PROOF_UPLOADED,  
								VICE_PRESIDENT_2_ADDRESS_PROOF_APPROVED,  
								VICE_PRESIDENT_2_PHOTO_ID_LAST_UPDATED,   
								VICE_PRESIDENT_2_PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_VICE_PRESIDENT_2_FORUM_MEMBER, 
								VICE_PRESIDENT_2_PAYMENT_DATE, 
								VICE_PRESIDENT_2_EXPIRATION_DATE, 
								IS_VICE_PRESIDENT_2_RENEWED,                  
								VICE_PRESIDENT_2_MEMBERSHIP_STATUS;
			END;            
		RETURN NEXT;
	END LOOP;
END;
$$
LANGUAGE 'plpgsql';

