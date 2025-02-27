# frozen_string_literal: true

# Note: even if the username is wrong, the url is still resolved correctly. Example:
# * https://foundation.app/@foundation/~/97376
#
# Unsupported patterns:
# * https://foundation.app/@ <- This seems to be a novelty account.
# * https://foundation.app/mochiiimo <- no @
# * https://foundation.app/collection/kgfgen

class Source::URL::Foundation < Source::URL
  attr_reader :username, :token_id, :work_id, :hash

  def self.match?(url)
    url.host.in?(%w[foundation.app assets.foundation.app f8n-ipfs-production.imgix.net f8n-production-collection-assets.imgix.net])
  end

  def parse
    case [host, *path_segments]

    # https://foundation.app/@mochiiimo
    # https://foundation.app/@KILLERGF
    in "foundation.app", /^@/ => username
      @username = username.delete_prefix("@")

    # https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2
    in "foundation.app", /^0x\h{39}/ => user_id
      @user_id = user_id

    # https://foundation.app/@mochiiimo/~/97376
    # https://foundation.app/@mochiiimo/foundation/97376
    # https://foundation.app/@KILLERGF/kgfgen/4
    in "foundation.app", /^@/ => username, collection, /^\d+/ => work_id
      @username = username.delete_prefix("@")
      @collection = collection
      @work_id = work_id

    # https://foundation.app/@asuka111art/dinner-with-cats-82426
    in "foundation.app", /^@/ => username, /^.+-\d+$/ => slug
      @username = username.delete_prefix("@")
      @work_id = slug.split("-").last

    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png?q=80&auto=format%2Ccompress&cs=srgb&max-w=1680&max-h=1680
    in "f8n-ipfs-production.imgix.net", hash, file
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
    in "f8n-production-collection-assets.imgix.net", token_id, work_id, hash, file
      @token_id = token_id
      @work_id = work_id
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png
    in "f8n-production-collection-assets.imgix.net", token_id, work_id, file
      @token_id = token_id
      @work_id = work_id

    # https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4
    in "assets.foundation.app", *subdirs, hash, file
      @hash = hash

    else
    end
  end

  def profile_url
    if username.present?
      "https://foundation.app/@#{username}"
    elsif user_id.present?
      "https://foundation.app/#{user_id}"
    end
  end

  def page_url
    return nil unless work_id.present?
    return nil if host == "f8n-production-collection-assets.imgix.net" && @hash.blank?
    # https://f8n-production-collection-assets.imgix.net/0xAcf67a11D93D22bbB51fddD9B039d43d5Db484Bc/3/nft.png cannot be normalized to a correct page url

    username = @username || "foundation"
    collection = @collection || "foundation"
    "https://foundation.app/@#{username}/#{collection}/#{work_id}"
  end

  def full_image_url
    if hash.present? && file_ext.present?
      "https://f8n-ipfs-production.imgix.net/#{hash}/nft.#{file_ext}"
    elsif host == "f8n-production-collection-assets.imgix.net" && token_id.present? && work_id.present? && file_ext.present?
      "https://f8n-production-collection-assets.imgix.net/#{token_id}/#{work_id}/nft.#{file_ext}"
    end
  end

  def ipfs_url
    return nil unless hash.present? && file_ext.present?
    "ipfs://#{hash}/nft.#{file_ext}"
  end
end
