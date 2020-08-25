module ProspectManagement
    class SetFieldService
  
      # -------------------------------------------------------------------------
      def call(logon:, prospect:, field_name:, newvalue:)
        ActiveRecord::Base.transaction do
  
          case field_name
          when 'email'
              # Combine if statements
              if newvalue.blank?
                return {error: 'You need to specify an email for this prospect.'}
              # Add bang and remove !=true
              elsif !EmailValidator.valid?(newvalue.strip.downcase)
                return {error: "Can't save email. Invalid value: '#{newvalue}'"}
              else
              # Use assign_attributes to have one less line
                prospect.assign_attributes(email: newvalue.strip.downcase, verified: 0)
              end
          # Consolidate similar when clauses
          when 'first_name', 'last_name', 'phone', 'title', 'role'
            prospect.assign_attributes(field_name => newvalue.strip)
          when 'score'
            prospect.score = newvalue.to_i
          else
            return {error: "Unknown field: '#{field_name}'"}
          end

          # Move begin...end block outside of case statement and combine it with the other call to #save!
          begin
            prospect.save!
          rescue ActiveRecord::RecordNotUnique
            return {error: 'Email already exists.'}
          rescue StandardError => e
            return {error: e.to_s}
          end
    
          return {}
        end
      end
      
      def original_call(logon:, prospect:, field_name:, newvalue:)
        ActiveRecord::Base.transaction do
  
          case field_name
          when 'email'
                  if newvalue.blank?
                    return {error: 'You need to specify an email for this prospect.'}
                  end

                  newvalue = newvalue.strip.downcase

                  if EmailValidator.valid?(newvalue) != true
                    return {error: "Can't save email. Invalid value: '#{newvalue}'"}
                  end
              
                  # prospect.verified = 0
                  prospect.email = newvalue
                  prospect.verified = 0
              
                  begin
                    prospect.save!
                  rescue ActiveRecord::RecordNotUnique
                      return {error: 'Email already exists.'}
                  rescue StandardError => e
                      return {error: e.to_s}
                  end
                  return {}

          when 'first_name'
            prospect.first_name = newvalue.strip
          when 'last_name'
            prospect.last_name = newvalue.strip
          when 'phone'
            prospect.phone = newvalue.strip
          when 'title'
            prospect.title = newvalue.strip
          when 'role'
            prospect.role = newvalue.strip
          when 'score'
            prospect.score = newvalue.to_i
          else
              return {error: "Unknown field: '#{field_name}'"}
          end
          prospect.save!
    
          return {}
        end

      end
    end
  end
  