DROP FUNCTION forum_summary_report ();

CREATE OR REPLACE FUNCTION public.member_summary_report ()
    RETURNS TABLE (
		FORUM_ID 									SY_CLUBS.id%TYPE,
		FORUM_NAME 								    SY_CLUBS.name%TYPE,		
		SYID                                        sadhak_profiles.SYID%TYPE,		
		FULLNAME                                    sadhak_profiles.FIRST_NAME%TYPE,
		MOBILE                                      sadhak_profiles.mobile%TYPE,
		EMAIL                                       sadhak_profiles.email%TYPE,
		COUNTRY 									db_countries.name % TYPE,
		STATE 										db_STATES.name % TYPE,
		CITY 										db_CITIES.name % TYPE,
		-- ADDRESS 									addresses.first_line%TYPE,
		-- MEMBERS_COUNT                                                         INT,
		-- CREATED_AT                                                            SY_CLUBS.CREATED_AT%TYPE,
		-- UPDATED_AT                                                            SY_CLUBS.UPDATED_AT%TYPE,
		PHOTO_ID_UPLOADED                                           VARCHAR(10),
		PHOTO_ID_APPROVED                                           VARCHAR(10),
		PHOTO_ID_PROOF_UPLOADED                                     VARCHAR(10),
		PHOTO_ID_PROOF_APPROVED                                     VARCHAR(10),
		PHOTO_ID_PROOF_NUMBER                                       advance_profiles.photo_id_proof_number%TYPE,
		ADDRESS_PROOF_UPLOADED                                      VARCHAR(10),
		ADDRESS_PROOF_APPROVED                                      VARCHAR(10),
		PHOTO_ID_LAST_UPDATED                                       IMAGES.UPDATED_AT%TYPE,
		PHOTO_ID_PROOF_LAST_UPDATED                                 IMAGES.UPDATED_AT%TYPE,
		PAYMENT_DATE                                                VARCHAR,
		PAYMENT_METHOD                                              sy_club_members.payment_method%TYPE,
		TRANSACTION_ID                                              sy_club_members.transaction_id%TYPE,				
		EXPIRATION_DATE                                             VARCHAR,
		STATUS                                             			VARCHAR,
		IS_RENEWED                                                  boolean,
		TRANSFERRED_TO_FORUM_ID										VARCHAR,
		DATE_OF_TRANSFER											VARCHAR,
		MEMBERSHIP_THROUGH_TRANSFER									boolean,
		TRANSFER_FROM_FORUM_ID										VARCHAR,
		ACTIVE_MEMBER_IN_CURRENT_FORUM                              boolean,
		FRESH_APPLICANT												boolean,
		PAST_MEMBER_FOR_1_YEAR										boolean,
		TOTAL_EPISODES_ATTENDED										INTEGER,
		MEMBER_ID													sy_club_members.id%TYPE
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
							    SYID, 
								FULLNAME, 
								MOBILE, 
								EMAIL, 
								PHOTO_ID_UPLOADED, 
								PHOTO_ID_APPROVED, 
								PHOTO_ID_PROOF_UPLOADED, 
								PHOTO_ID_PROOF_APPROVED, 
								PHOTO_ID_PROOF_NUMBER,   
								ADDRESS_PROOF_UPLOADED,  
								ADDRESS_PROOF_APPROVED,  
								PHOTO_ID_LAST_UPDATED,   
								PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_FORUM_MEMBER, 
								PAYMENT_DATE, 
								EXPIRATION_DATE, 
								IS_RENEWED,                  
								MEMBERSHIP_STATUS;
				SELECT * FROM role_report(FORUM_ID, 2) INTO
							    VICE_1_SYID, 
								VICE_1_FULLNAME, 
								VICE_1_MOBILE, 
								VICE_1_EMAIL, 
								VICE_1_PHOTO_ID_UPLOADED, 
								VICE_1_PHOTO_ID_APPROVED, 
								VICE_1_PHOTO_ID_PROOF_UPLOADED, 
								VICE_1_PHOTO_ID_PROOF_APPROVED, 
								VICE_1_PHOTO_ID_PROOF_NUMBER,   
								VICE_1_ADDRESS_PROOF_UPLOADED,  
								VICE_1_ADDRESS_PROOF_APPROVED,  
								VICE_1_PHOTO_ID_LAST_UPDATED,   
								VICE_1_PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_VICE_1_FORUM_MEMBER, 
								VICE_1_PAYMENT_DATE, 
								VICE_1_EXPIRATION_DATE, 
								IS_VICE_1_RENEWED,                  
								VICE_1_MEMBERSHIP_STATUS ;
				SELECT * FROM role_report(FORUM_ID, 3) INTO
						       	VICE_2_SYID, 
								VICE_2_FULLNAME, 
								VICE_2_MOBILE, 
								VICE_2_EMAIL, 
								VICE_2_PHOTO_ID_UPLOADED, 
								VICE_2_PHOTO_ID_APPROVED, 
								VICE_2_PHOTO_ID_PROOF_UPLOADED, 
								VICE_2_PHOTO_ID_PROOF_APPROVED, 
								VICE_2_PHOTO_ID_PROOF_NUMBER,   
								VICE_2_ADDRESS_PROOF_UPLOADED,  
								VICE_2_ADDRESS_PROOF_APPROVED,  
								VICE_2_PHOTO_ID_LAST_UPDATED,   
								VICE_2_PHOTO_ID_PROOF_LAST_UPDATED, 
								IS_VICE_2_FORUM_MEMBER, 
								VICE_2_PAYMENT_DATE, 
								VICE_2_EXPIRATION_DATE, 
								IS_VICE_2_RENEWED,                  
								VICE_2_MEMBERSHIP_STATUS;
			END;            
		RETURN NEXT;
	END LOOP;
END;
$$
LANGUAGE 'plpgsql';

