--DROP FUNCTION ROLE_REPORT(FORUM_ID	SY_CLUBS.id%TYPE, ROLE_ID SY_CLUB_USER_ROLES.id%TYPE);
CREATE OR REPLACE FUNCTION public.ROLE_REPORT(FORUM_ID	SY_CLUBS.id%TYPE, ROLE_ID SY_CLUB_USER_ROLES.id%TYPE,
		OUT ABC_SYID                                                        sadhak_profiles.SYID%TYPE,
		OUT ABC_FULLNAME                                                    sadhak_profiles.FIRST_NAME%TYPE,
		OUT ABC_MOBILE                                                      sadhak_profiles.mobile%TYPE,
		OUT ABC_EMAIL                                                       sadhak_profiles.email%TYPE,
		OUT ABC_PHOTO_ID_UPLOADED                                           VARCHAR(10),
		OUT ABC_PHOTO_ID_APPROVED                                           VARCHAR(10),
		OUT ABC_PHOTO_ID_PROOF_UPLOADED                                     VARCHAR(10),
		OUT ABC_PHOTO_ID_PROOF_APPROVED                                     VARCHAR(10),
		OUT ABC_PHOTO_ID_PROOF_NUMBER                                       advance_profiles.photo_id_proof_number%TYPE,
		OUT ABC_ADDRESS_PROOF_UPLOADED                                      VARCHAR(10),
		OUT ABC_ADDRESS_PROOF_APPROVED                                      VARCHAR(10),
		OUT ABC_PHOTO_ID_LAST_UPDATED                                       IMAGES.UPDATED_AT%TYPE,
		OUT ABC_PHOTO_ID_PROOF_LAST_UPDATED                                 IMAGES.UPDATED_AT%TYPE,
		OUT IS_ABC_FORUM_MEMBER                                             boolean,
		OUT ABC_PAYMENT_DATE                                                VARCHAR,
		OUT ABC_EXPIRATION_DATE                                             VARCHAR,
		OUT IS_ABC_RENEWED                                                  boolean,
		OUT ABC_MEMBERSHIP_STATUS                                           VARCHAR(10)		
  ) AS $$
DECLARE    
v_ABC_id sadhak_profiles.id % TYPE := NULL;   
v_ABC_aid advance_profiles.id % TYPE := NULL;
temp images.id % TYPE := NULL;
v_temp sadhak_profiles.id % TYPE := NULL;
v_member_rec record := NULL;	
v_member_rec1 record;
v_member_id sy_club_members.id % TYPE;
v_is_renewed record;
BEGIN
-- INIT RETURN DATA
    ABC_SYID := NULL;
    ABC_FULLNAME := NULL;
    ABC_MOBILE := NULL;
    ABC_EMAIL := NULL;
    ABC_PHOTO_ID_UPLOADED := NULL;
    ABC_PHOTO_ID_APPROVED := NULL;
    ABC_PHOTO_ID_PROOF_UPLOADED := NULL;
    ABC_PHOTO_ID_PROOF_APPROVED := NULL;
    ABC_PHOTO_ID_PROOF_NUMBER := NULL;  
    ABC_ADDRESS_PROOF_UPLOADED := NULL; 
    ABC_ADDRESS_PROOF_APPROVED := NULL; 
    ABC_PHOTO_ID_LAST_UPDATED := NULL;  
    ABC_PHOTO_ID_PROOF_LAST_UPDATED := NULL;
    IS_ABC_FORUM_MEMBER := NULL;
    ABC_PAYMENT_DATE := NULL;
    ABC_EXPIRATION_DATE := NULL;
    IS_ABC_RENEWED := NULL;                 
    ABC_MEMBERSHIP_STATUS := NULL;

    SELECT 
        spr.id, spr.syid, initcap(concat(spr.first_name, ' ', spr.middle_name, ' ', spr.last_name)),
        spr.mobile, spr.email,
        CASE profile_photo_status WHEN 1 THEN 'Yes' ELSE 'No' END,
        CASE photo_id_status WHEN 1 THEN 'Yes' ELSE 'No' END,
        CASE address_proof_status WHEN 1 THEN 'Yes' ELSE 'No' END,													 													 
        apr.id, apr.photo_id_proof_number 
    INTO 
        v_ABC_id, ABC_SYID, ABC_FULLNAME, 
        ABC_MOBILE, ABC_EMAIL,
        ABC_PHOTO_ID_APPROVED, 
        ABC_PHOTO_ID_PROOF_APPROVED,
        ABC_ADDRESS_PROOF_APPROVED,												 
        v_ABC_aid, ABC_PHOTO_ID_PROOF_NUMBER
    FROM
        sy_club_sadhak_profile_associations csp
        INNER JOIN sadhak_profiles spr ON (csp.sadhak_profile_id = spr.id)
        LEFT JOIN advance_profiles apr ON (spr.id = apr.sadhak_profile_id
                AND apr.deleted_at IS NULL)
    WHERE
        csp. "deleted_at" IS NULL
        AND csp. "sy_club_user_role_id" = ROLE_ID
        AND csp. "sy_club_id" = FORUM_ID -- scb.id
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE NOTICE 'No Data Found';
        RETURN;
    END IF;
					
-- 	ABC_PHOTO_ID_UPLOADED
    SELECT
        img.id INTO temp
    FROM
        advance_profiles apr
        INNER JOIN images img ON (img. "imageable_id" = apr.id
                AND img. "imageable_type" = 'AdvanceProfilePhotograph')
    WHERE
        apr.sadhak_profile_id = v_ABC_id
        AND apr. "deleted_at" IS NULL
        AND img. "deleted_at" IS NULL
    LIMIT 1;

    IF FOUND THEN
        ABC_PHOTO_ID_UPLOADED := 'Yes';    
    ELSE
        ABC_PHOTO_ID_UPLOADED := 'No';
    END IF;

-- 	17. ABC_PHOTO_ID_PROOF_UPLOADED
    SELECT
        img.id INTO temp
    FROM
        advance_profiles apr
        INNER JOIN images img ON (img. "imageable_id" = apr.id
                AND img. "imageable_type" = 'AdvanceProfileIdentityProof')
    WHERE
        apr.sadhak_profile_id = v_ABC_id
        AND apr. "deleted_at" IS NULL
        AND img. "deleted_at" IS NULL
    LIMIT 1;

    IF FOUND THEN
        ABC_PHOTO_ID_PROOF_UPLOADED := 'Yes';    
    ELSE
        ABC_PHOTO_ID_PROOF_UPLOADED := 'No';
    END IF;

-- 20. ABC_ADDRESS_PROOF_UPLOADED
    SELECT
        img.id INTO temp
    FROM
        advance_profiles apr
        INNER JOIN images img ON (img. "imageable_id" = apr.id
                AND img. "imageable_type" = 'AdvanceProfileAddressProof')
    WHERE
        apr.sadhak_profile_id = v_ABC_id
        AND apr. "deleted_at" IS NULL
        AND img. "deleted_at" IS NULL
    LIMIT 1;

    IF FOUND THEN
        ABC_ADDRESS_PROOF_UPLOADED := 'Yes';    
    ELSE
        ABC_ADDRESS_PROOF_UPLOADED := 'No';
    END IF;

-- 22. ABC_PHOTO_ID_LAST_UPDATED
    SELECT
        img.updated_at INTO ABC_PHOTO_ID_LAST_UPDATED
    FROM
        advance_profiles apr
        INNER JOIN images img ON (img. "imageable_id" = apr.id
                AND img. "imageable_type" = 'AdvanceProfilePhotograph')
    WHERE
        apr.sadhak_profile_id = v_ABC_id
        AND apr. "deleted_at" IS NULL
        AND img. "deleted_at" IS NULL
    LIMIT 1;

														
-- 23. ABC_PHOTO_ID_PROOF_LAST_UPDATED													 
    SELECT
        img.updated_at INTO ABC_PHOTO_ID_PROOF_LAST_UPDATED
    FROM
        advance_profiles apr
        INNER JOIN images img ON (img. "imageable_id" = apr.id
                AND img. "imageable_type" = 'AdvanceProfileIdentityProof')
    WHERE
        apr.sadhak_profile_id = v_ABC_id
        AND apr. "deleted_at" IS NULL
        AND img. "deleted_at" IS NULL
    LIMIT 1;

-- 24. IS_ABC_FORUM_MEMBER
    SELECT 
        spr.id INTO v_temp
    FROM
        sadhak_profiles spr
        INNER JOIN sy_club_members scm ON spr. "id" = scm. "sadhak_profile_id"					
                    WHERE
        spr. "deleted_at" IS NULL
        AND spr. "deleted_at" IS NULL
        AND scm. "sy_club_id" = FORUM_ID
        AND scm. "status" = 1
        AND scm. "is_deleted" = FALSE
        AND scm. "event_registration_id" IS NOT NULL
        AND spr.id = v_ABC_id;

    IF FOUND THEN
        IS_ABC_FORUM_MEMBER := true;
    ELSE
        IS_ABC_FORUM_MEMBER := false;
    END IF;
	
-- 26. ABC_EXPIRATION_DATE
                                  
    SELECT  scm.id, scm.event_registration_id , scm.payment_method, scm.transaction_id, 
            scm.metadata, to_char(ert.created_at::DATE+ert.expires_at-1, 'DD Mon YYYY') exipres_at,
            scm.status
    INTO    v_member_rec
    FROM "sy_club_members" scm INNER JOIN "event_registrations" ert ON (scm.event_registration_id = ert.id AND ert."deleted_at" IS NULL)
    WHERE scm."deleted_at" IS NULL 
    AND (scm.event_registration_id IS NOT NULL 
    AND scm.status = 1 AND scm.sy_club_id = FORUM_ID AND scm.sadhak_profile_id = v_ABC_id) 
    ORDER BY scm."id" DESC LIMIT 1;		
    
    IF NOT FOUND THEN
        RAISE NOTICE 'member no_data_found';
            SELECT  scm.id, scm.event_registration_id , scm.payment_method, scm.transaction_id, 
            scm.metadata, to_char(ert.created_at::DATE+ert.expires_at-1, 'DD Mon YYYY') exipres_at,
            scm.status
        INTO    v_member_rec
        FROM "sy_club_members" scm INNER JOIN "event_registrations" ert ON (scm.event_registration_id = ert.id AND ert."deleted_at" IS NULL)
        WHERE scm."deleted_at" IS NULL 
        AND (scm.event_registration_id IS NOT NULL 
        AND scm.status = 2 AND scm.sy_club_id = FORUM_ID AND scm.sadhak_profile_id = v_ABC_id) 
        ORDER BY scm."id" DESC LIMIT 1;		        
    END IF;
    ABC_EXPIRATION_DATE := v_member_rec.exipres_at;

				
-- 25. ABC_PAYMENT_DATE
    RAISE NOTICE 'Start Compute ABC_PAYMENT_DATE, %', v_member_rec.id;
    IF v_member_rec.id IS NOT NULL THEN
        -- direct pay
        IF (v_member_rec.metadata not like 'Transferred_from_member_id%') THEN
            ABC_PAYMENT_DATE := get_payment_info(v_member_rec.payment_method, v_member_rec.transaction_id);
            ABC_PAYMENT_DATE := COALESCE(ABC_PAYMENT_DATE, COALESCE(v_member_rec1.club_joining_date,  v_member_rec1.created_at));
        -- transfer from member
        ELSE
            v_member_id := (REGEXP_MATCHES(v_member_rec.metadata, '[0-9]+'))[1]::integer;
            SELECT  scm.payment_method, scm.transaction_id, scm.club_joining_date, scm.created_at INTO STRICT v_member_rec1 FROM "sy_club_members" scm WHERE id = v_member_id;
            ABC_PAYMENT_DATE := get_payment_info(v_member_rec1.payment_method, v_member_rec1.transaction_id);
            ABC_PAYMENT_DATE := COALESCE(ABC_PAYMENT_DATE, COALESCE(v_member_rec1.club_joining_date,  v_member_rec1.created_at));
        END IF;
    END IF;

--27.28 IS_ABC_RENEWED, ABC_MEMBERSHIP_STATUS
    SELECT  "sy_club_members".id, event_registration_id 
    INTO v_is_renewed 
    FROM "sy_club_members" 
    WHERE "sy_club_members"."deleted_at" IS NULL AND (event_registration_id IS NOT NULL AND status IN (3) AND sy_club_id = FORUM_ID AND sadhak_profile_id = v_ABC_id) ORDER BY "sy_club_members".created_at DESC LIMIT 1;
    
	RAISE NOTICE '27.28 IS_ABC_RENEWED, ABC_MEMBERSHIP_STATUS % %', v_is_renewed.event_registration_id, v_member_rec.event_registration_id;										   
	IF FOUND AND v_is_renewed.event_registration_id = v_member_rec.event_registration_id THEN 
        IS_ABC_RENEWED := true;
    ELSE
        IS_ABC_RENEWED := false;
    END IF;

    ABC_MEMBERSHIP_STATUS := 'NA';
    IF v_member_rec.id IS NOT NULL THEN
        IF v_member_rec.status = 1 THEN
            ABC_MEMBERSHIP_STATUS := 'Approve';
        ELSIF v_member_rec.status = 2 THEN
            ABC_MEMBERSHIP_STATUS := 'Expired';
        END IF;												
    END IF;

    RETURN;
END;
$$
LANGUAGE 'plpgsql';