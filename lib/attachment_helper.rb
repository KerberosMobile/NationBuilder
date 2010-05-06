  module AttachmentHelper

    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    module ClassMethods
      def has_attachment(name, options = {})

        # generates a string containing the singular model name and the pluralized attachment name.
        # Examples: "user_avatars" or "asset_uploads" or "message_previews"
        attachment_owner    = self.table_name.singularize
        attachment_folder   = "#{attachment_owner}_#{name.to_s.pluralize}"

        # we want to create a path for the upload that looks like:
        # message_previews/00/11/22/001122deadbeef/thumbnail.png
        attachment_path     = "#{attachment_folder}/:uuid_partition/:uuid/:style.:extension"

        if Rails.env.production? || Rails.env.development?
          options[:storage]         ||= :s3
          options[:s3_credentials]  ||= S3_CONFIG
        else
          # For local Dev/Test envs, use the default filesystem, but separate the environments
          # into different folders, so you can delete test files without breaking dev files.
          options[:path]  ||= ":rails_root/public/system/attachments/#{Rails.env}/#{attachment_path}"
          options[:url]   ||= "/system/attachments/#{Rails.env}/#{attachment_path}"
        end

        # pass things off to paperclip.
        has_attached_file name, options
      end
    end
  end

