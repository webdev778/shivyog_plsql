	
	sy_clubs = SyClub.active_global
	# SyClub Load (1.5ms)  
	# SELECT  "sy_clubs".* FROM "sy_clubs" INNER JOIN "addresses" ON "addresses"."addressable_id" = "sy_clubs"."id" 
	# AND "addresses"."deleted_at" IS NULL AND "addresses"."addressable_type" = $1 
	# WHERE "sy_clubs"."is_deleted" = $2 AND NOT (("addresses"."country_id" = $3 OR "addresses"."country_id" IS NULL)) 
	# AND "sy_clubs"."status" != $4 ORDER BY "sy_clubs"."id" ASC LIMIT $5  
	# [["addressable_type", "SyClub"], ["is_deleted", false], ["country_id", 113], ["status", 1], ["LIMIT", 11]]
	
	def generate_summary_report(sy_clubs, info)
      club_roles = SyClubUserRole.all.collect{|r| {id: r.id, role_name: r.role_name}}.each {|r| r[:role_name].upcase!}
      # SyClubUserRole Load (0.4ms)  SELECT "sy_club_user_roles".* FROM "sy_club_user_roles"
      # => [{:id=>1, :role_name=>"PRESIDENT"}, {:id=>3, :role_name=>"VICE-PRESIDENT-2"}, {:id=>2, :role_name=>"VICE-PRESIDENT-1"}]
      
      #columns_for_member_list = %w(SYID FULLNAME MOBILE EMAIL PHOTO_ID_UPLOADED PHOTO_ID_APPROVED PHOTO_ID_PROOF_UPLOADED PHOTO_ID_PROOF_APPROVED PHOTO_ID_PROOF_NUMBER ADDRESS_PROOF_UPLOADED ADDRESS_PROOF_APPROVED PHOTO_ID_LAST_UPDATED PHOTO_ID_PROOF_LAST_UPDATED)
      #columns_for_forum_list = %w(FORUM_ID COUNTRY STATE CITY ADDRESS FORUM_NAME MEMBERS_COUNT CREATED_AT UPDATED_AT')      
      club_roles.each do |m_role|
        columns_for_member_list.each do |m_detail_column|
          columns_for_forum_list.push(m_role[:role_name] + '_' + m_detail_column)
        end
        columns_for_forum_list.push("IS_#{m_role[:role_name]}_FORUM_MEMBER?")
        columns_for_forum_list.push("#{m_role[:role_name]}_PAYMENT_DATE")
        columns_for_forum_list.push("#{m_role[:role_name]}_EXPIRATION_DATE")
        columns_for_forum_list.push("IS_#{m_role[:role_name]}_RENEWED?")
        columns_for_forum_list.push("#{m_role[:role_name]}_MEMBERSHIP_STATUS")
      end

      forum_list = []

      sy_clubs.includes(:address).find_in_batches(batch_size: 200).with_index do |batch, INDEX|      
      # SELECT * FROM "sy_clubs" INNER JOIN "addresses" ON "addresses"."addressable_id" = "sy_clubs"."id"
      # AND "addresses"."deleted_at" IS NULL AND "addresses"."addressable_type" = 'SyClub'
      # WHERE "sy_clubs"."is_deleted" = false AND NOT (("addresses"."country_id" = 113 OR "addresses"."country_id" IS NULL))
      # AND "sy_clubs"."status" != 1
   		# => ROWS:408
		
        batch.each do |club|

          club_address = club.address
          member_sadhak_ids = club.approved_members.pluck(:id)
          members_count = member_sadhak_ids.size

        # get member count of club
				# SELECT "sadhak_profiles"."id" FROM 
				# "sadhak_profiles" INNER JOIN "sy_club_members" ON "sadhak_profiles"."id" = "sy_club_members"."sadhak_profile_id" 
				# WHERE "sadhak_profiles"."deleted_at" IS NULL AND "sy_club_members"."deleted_at" IS NULL 
				# AND "sy_club_members"."sy_club_id" = $1 AND "sy_club_members"."status" = $2 AND "sy_club_members"."is_deleted" = $3
				# AND "sy_club_members"."event_registration_id" IS NOT NULL

			
          club_admins = club.sy_club_sadhak_profile_associations.select{|a| a.sy_club_user_role_id != nil}
                            .collect{|s|
                              {
                                  sadhak_profile_id: s.sadhak_profile_id,
                                  fullname: s.try(:sadhak_profile).try(:full_name).try(:titleize),
                                  sy_club_user_role_id: s.sy_club_user_role_id,
                                  syid: s.try(:sadhak_profile).syid,
                                  email: s.try(:sadhak_profile).try(:email),
                                  mobile: s.try(:sadhak_profile).try(:mobile),
                                  photo_id_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No',
                                  photo_id_approved: s.try(:sadhak_profile).try(:profile_photo_status) == 'pp_success' ? 'Yes' : 'No',
                                  photo_id_proof_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_identity_proof).present? ? 'Yes' : 'No',
                                  photo_id_proof_approved: s.try(:sadhak_profile).try(:photo_id_status) == 'pi_success' ? 'Yes' : 'No',
                                  photo_id_proof_number: s.try(:sadhak_profile).try(:advance_profile).try(:photo_id_proof_number).to_s,
                                  address_proof_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_address_proof).present? ? 'Yes' : 'No',
                                  address_proof_approved: s.try(:sadhak_profile).try(:address_proof_status) == 'ap_success' ? 'Yes' : 'No',
                                  photo_id_last_updated: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_photograph).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p'),
                                  photo_id_proof_last_updated: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_identity_proof).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
                              }
                            }
          
          # SadhakProfile Load (0.4ms)  SELECT  "sadhak_profiles".* FROM "sadhak_profiles" WHERE "sadhak_profiles"."deleted_at" IS NULL AND "sadhak_profiles"."id" = $1 LIMIT $2  [["id", 11619], ["LIMIT", 1]]
          # AdvanceProfile Load (13.6ms)  SELECT  "advance_profiles".* FROM "advance_profiles" WHERE "advance_profiles"."deleted_at" IS NULL AND "advance_profiles"."sadhak_profile_id" = $1 LIMIT $2  [["sadhak_profile_id", 11619], ["LIMIT", 1]]
          # Image Load (1.0ms)  SELECT  "images".* FROM "images" WHERE "images"."deleted_at" IS NULL AND "images"."imageable_id" = $1 AND "images"."imageable_type" = $2 LIMIT $3  [["imageable_id", 10314], ["imageable_type", "AdvanceProfilePhotograph"], ["LIMIT", 1]]
          # Image Load (0.2ms)  SELECT  "images".* FROM "images" WHERE "images"."deleted_at" IS NULL AND "images"."imageable_id" = $1 AND "images"."imageable_type" = $2 LIMIT $3  [["imageable_id", 10314], ["imageable_type", "AdvanceProfileIdentityProof"], ["LIMIT", 1]]
          # Image Load (0.2ms)  SELECT  "images".* FROM "images" WHERE "images"."deleted_at" IS NULL AND "images"."imageable_id" = $1 AND "images"."imageable_type" = $2 LIMIT $3  [["imageable_id", 10314], ["imageable_type", "AdvanceProfileAddressProof"], ["LIMIT", 1]]
          # SadhakProfile Load (60.7ms)  SELECT  "sadhak_profiles".* FROM "sadhak_profiles" WHERE "sadhak_profiles"."deleted_at" IS NULL AND "sadhak_profiles"."id" = $1 LIMIT $2  [["id", 45322], ["LIMIT", 1]]
          # AdvanceProfile Load (23.1ms)  SELECT  "advance_profiles".* FROM "advance_profiles" WHERE "advance_profiles"."deleted_at" IS NULL AND "advance_profiles"."sadhak_profile_id" = $1 LIMIT $2  [["sadhak_profile_id", 45322], ["LIMIT", 1]]		
          
          #  Used TABLES : sy_clubs, sy_club_sadhak_profile_associations, sadhak_profiles, advance_profiles, images

		                            

          hash = Array.new
          hash.push(club.id)
          hash.push(club_address.try(:country_name))
          hash.push(club_address.try(:state_name))
          hash.push(club_address.try(:city_name))
          hash.push(club_address.try(:full_address))

          hash.push(club.name.try(:titleize))
          hash.push(members_count)
          hash.push(club.created_at.strftime('%F %T'))
          hash.push(club.updated_at.strftime('%F %T'))

          # Push board members details
          club_roles.each do |club_role|
            role = (club_admins.find{|c| c[:sy_club_user_role_id] == club_role[:id]} || {})
            columns_for_member_list.each do |m_detail_column|
              hash.push(role.present? ? role[m_detail_column.downcase.to_sym] : 'NA')
            end

            # Is active member of current forum
            hash.push(role.present? ? member_sadhak_ids.include?(role[:sadhak_profile_id]) : 'NA')

            # Find active membership record
            member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:approve).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).last
            # SyClubMember Load (31.9ms)  
            # SELECT  "sy_club_members".*  FROM "sy_club_members" WHERE "sy_club_members"."deleted_at" IS NULL AND (event_registration_id IS NOT NULL AND status IN (1) AND sy_club_id = 551 AND sadhak_profile_id = 11619) ORDER BY "sy_club_members"."id" DESC LIMIT 1
            # EventRegistration Load (0.4ms)  
            # SELECT "event_registrations".* FROM "event_registrations" WHERE "event_registrations"."deleted_at" IS NULL AND "event_registrations"."id" = 493494
  
            # If active membership not found then search in expired members
            unless member.present?
              member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:expired).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).last
              # SyClubMember Load (0.5ms)  SELECT  "sy_club_members".* FROM "sy_club_members" WHERE "sy_club_members"."deleted_at" IS NULL AND (event_registration_id IS NOT NULL AND status IN (2) AND sy_club_id = 551 AND sadhak_profile_id = 11619) ORDER BY "sy_club_members"."id" DESC LIMIT 1
            end

            # Find associated registration
            registration = member.try(:event_registration)

            # Compute Payment Date
            payment_date = nil
            if member.present?
              loop do
                gateway = (TransferredEventOrder.gateways.find{|g| g[:payment_method] == member.payment_method} || {})
                payment_date = gateway[:model].try(:constantize).try(:where, {gateway[:transaction_id] => member.transaction_id, status: gateway[:success]}).try(:last).try(:created_at)
                if payment_date.nil?
                  if member.metadata.to_s.include?('Transferred_from_member_id')
                    member = SyClubMember.unscoped.find_by_id(member.metadata.to_s[/-?\d+/].to_i)
                  else
                    payment_date = (member.club_joining_date || member.created_at)
                    member = nil
                  end
                end
                break if (payment_date.present? || member.nil?)
              end
            end
            # cal payment_date module
				    # StripeSubscription Load (22.9ms)  SELECT  "stripe_subscriptions".* FROM "stripe_subscriptions" WHERE "stripe_subscriptions"."card" = $1 AND "stripe_subscriptions"."status" = $2 ORDER BY "stripe_subscriptions"."id" DESC LIMIT $3  [["card", "tok_1D3jEuDddDExZeOmTrR9OjKJ"], ["status", 1], ["LIMIT", 1]]
            
            hash.push(payment_date.present? ? payment_date.try(:strftime, ('%b %d, %Y')) : 'NA')

            # Push expiration date
            hash.push(registration.present? ? "#{(registration.created_at.to_date + registration.expires_at - 1).strftime('%b %d, %Y')}" : 'NA')

            # Is renewed
            renewed_member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:renewed).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).order('created_at DESC').first
            # SyClubMember Load (0.6ms)  SELECT  "sy_club_members".* FROM "sy_club_members" WHERE "sy_club_members"."deleted_at" IS NULL AND (event_registration_id IS NOT NULL AND status IN (3) AND sy_club_id = 551 AND sadhak_profile_id = 11619) ORDER BY created_at DESC LIMIT $1  [["LIMIT", 1]]
			      # EventRegistration Load (55.1ms)  SELECT "event_registrations".* FROM "event_registrations" WHERE "event_registrations"."deleted_at" IS NULL AND "event_registrations"."id" = $1  [["id", 310068]]
			   
            is_renewed = (renewed_member.present? and renewed_member.event_registration == registration.try(:parent_registration))
            hash.push(is_renewed)

            if member.present?
              if member.approve?
                membership_status = 'Approve'
              elsif member.expired?
                membership_status = 'Expired'
              end
            else
              membership_status = 'NA'
            end

            hash.push(membership_status)

          end
          forum_list.push(hash)
        end

      end
