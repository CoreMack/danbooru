require 'test_helper'

class ArtistURLTest < ActiveSupport::TestCase
  def assert_search_equals(results, conditions)
    assert_equal(results.map(&:id), subject.search(conditions).map(&:id))
  end

  context "An artist url" do
    setup do
      CurrentUser.user = FactoryBot.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "allow urls to be marked as inactive" do
      url = create(:artist_url, url: "http://monet.com", is_active: false)
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
      assert_equal("-http://monet.com", url.to_s)
    end

    should "disallow invalid urls" do
      urls = [
        build(:artist_url, url: ":www.example.com"),
        build(:artist_url, url: "http://http://www.example.com"),
      ]

      assert_equal(false, urls[0].valid?)
      assert_match(/is malformed/, urls[0].errors.full_messages.join)
      assert_equal(false, urls[1].valid?)
      assert_match(/that does not contain a dot/, urls[1].errors.full_messages.join)
    end

    should "automatically add http:// if missing" do
      url = create(:artist_url, url: "example.com")
      assert_equal("http://example.com", url.url)
      assert_equal("http://example.com/", url.normalized_url)
    end

    should "normalize trailing slashes" do
      url = create(:artist_url, url: "http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)

      url = create(:artist_url, url: "http://monet.com/")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
    end

    should "normalise https" do
      url = create(:artist_url, url: "https://google.com")
      assert_equal("https://google.com", url.url)
      assert_equal("http://google.com/", url.normalized_url)
    end

    should "normalise domains to lowercase" do
      url = create(:artist_url, url: "https://ArtistName.example.com")
      assert_equal("https://artistname.example.com", url.url)
      assert_equal("http://artistname.example.com/", url.normalized_url)
    end

    should "normalize ArtStation urls" do
      url = create(:artist_url, url: "https://artstation.com/koyorin")
      assert_equal("https://www.artstation.com/koyorin", url.url)
      assert_equal("http://www.artstation.com/koyorin/", url.normalized_url)

      url = create(:artist_url, url: "https://koyorin.artstation.com")
      assert_equal("https://www.artstation.com/koyorin", url.url)
      assert_equal("http://www.artstation.com/koyorin/", url.normalized_url)

      url = create(:artist_url, url: "https://www.artstation.com/artist/koyorin/albums/all/")
      assert_equal("https://www.artstation.com/koyorin", url.url)
      assert_equal("http://www.artstation.com/koyorin/", url.normalized_url)
    end

    should "normalize fc2 urls" do
      url = create(:artist_url, url: "http://silencexs.blog106.fc2.com/")

      assert_equal("http://silencexs.blog.fc2.com", url.url)
      assert_equal("http://silencexs.blog.fc2.com/", url.normalized_url)
    end

    should "normalize deviant art artist urls" do
      url = create(:artist_url, url: "https://noizave.deviantart.com")

      assert_equal("https://www.deviantart.com/noizave", url.url)
      assert_equal("http://www.deviantart.com/noizave/", url.normalized_url)
    end

    should "normalize nico seiga artist urls" do
      url = create(:artist_url, url: "http://seiga.nicovideo.jp/user/illust/7017777")
      assert_equal("https://seiga.nicovideo.jp/user/illust/7017777", url.url)
      assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", url.normalized_url)

      url = create(:artist_url, url: "http://seiga.nicovideo.jp/manga/list?user_id=23839737")
      assert_equal("https://seiga.nicovideo.jp/manga/list?user_id=23839737", url.url)
      assert_equal("http://seiga.nicovideo.jp/manga/list?user_id=23839737/", url.normalized_url)

      url = create(:artist_url, url: "https://www.nicovideo.jp/user/20446930/mylist/28674289")
      assert_equal("https://www.nicovideo.jp/user/20446930", url.url)
      assert_equal("http://www.nicovideo.jp/user/20446930/", url.normalized_url)
    end

    should "normalize hentai foundry artist urls" do
      url = create(:artist_url, url: "http://www.hentai-foundry.com/user/kajinman/profile")

      assert_equal("https://www.hentai-foundry.com/user/kajinman", url.url)
      assert_equal("http://www.hentai-foundry.com/user/kajinman/", url.normalized_url)
    end

    should "normalize pixiv stacc urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/stacc/evazion/")

      assert_equal("https://www.pixiv.net/stacc/evazion", url.url)
      assert_equal("http://www.pixiv.net/stacc/evazion/", url.normalized_url)
    end

    should "normalize pixiv fanbox account urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/fanbox/creator/3113804/post")

      assert_equal("https://www.pixiv.net/fanbox/creator/3113804", url.url)
      assert_equal("http://www.pixiv.net/fanbox/creator/3113804/", url.normalized_url)

      url = create(:artist_url, url: "http://omu001.fanbox.cc/posts/39714")
      assert_equal("https://omu001.fanbox.cc", url.url)
      assert_equal("http://omu001.fanbox.cc/", url.normalized_url)
    end

    should "normalize pixiv.net/user/123 urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/en/users/123")

      assert_equal("https://www.pixiv.net/users/123", url.url)
      assert_equal("http://www.pixiv.net/users/123/", url.normalized_url)
    end

    should "normalize twitter urls" do
      url = create(:artist_url, url: "https://twitter.com/aoimanabu/status/892370963630743552")
      assert_equal("https://twitter.com/aoimanabu", url.url)
      assert_equal("http://twitter.com/aoimanabu/", url.normalized_url)

      url = create(:artist_url, url: "https://twitter.com/BLAH")
      assert_equal("https://twitter.com/BLAH", url.url)
      assert_equal("http://twitter.com/BLAH/", url.normalized_url)
    end

    should "normalize https://twitter.com/intent/user?user_id=* urls" do
      url = create(:artist_url, url: "https://twitter.com/intent/user?user_id=2784590030")

      assert_equal("https://twitter.com/intent/user?user_id=2784590030", url.url)
      assert_equal("http://twitter.com/intent/user?user_id=2784590030/", url.normalized_url)
    end

    should "normalize twitpic urls" do
      url = create(:artist_url, url: "http://twitpic.com/photos/mirakichi")
      assert_equal("http://twitpic.com/photos/mirakichi", url.url)
      assert_equal("http://twitpic.com/photos/mirakichi/", url.normalized_url)
    end

    should "normalize nijie urls" do
      url = create(:artist_url, url: "https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png")
      assert_equal("https://nijie.info/members.php?id=236014", url.url)
      assert_equal("http://nijie.info/members.php?id=236014/", url.normalized_url)

      url = create(:artist_url, url: "http://nijie.info/members.php?id=161703")
      assert_equal("https://nijie.info/members.php?id=161703", url.url)
      assert_equal("http://nijie.info/members.php?id=161703/", url.normalized_url)

      url = create(:artist_url, url: "http://www.nijie.info/members_illust.php?id=161703")
      assert_equal("https://nijie.info/members.php?id=161703", url.url)
      assert_equal("http://nijie.info/members.php?id=161703/", url.normalized_url)

      url = create(:artist_url, url: "http://nijie.info/invalid.php")
      assert_equal("http://nijie.info/invalid.php", url.url)
      assert_equal("http://nijie.info/invalid.php/", url.normalized_url)
    end

    should "normalize pawoo.net urls" do
      url = create(:artist_url, url: "http://pawoo.net/@evazion/19451018")
      assert_equal("https://pawoo.net/@evazion", url.url)
      assert_equal("http://pawoo.net/@evazion/", url.normalized_url)

      url = create(:artist_url, url: "http://pawoo.net/users/evazion/media")
      assert_equal("https://pawoo.net/@evazion", url.url)
      assert_equal("http://pawoo.net/@evazion/", url.normalized_url)
    end

    should "normalize baraag.net urls" do
      url = create(:artist_url, url: "http://baraag.net/@curator/102270656480174153")
      assert_equal("https://baraag.net/@curator", url.url)
      assert_equal("http://baraag.net/@curator/", url.normalized_url)
    end

    should "normalize Instagram urls" do
      url = create(:artist_url, url: "http://instagram.com/itomugi")
      assert_equal("https://www.instagram.com/itomugi/", url.url)
      assert_equal("http://www.instagram.com/itomugi/", url.normalized_url)
    end

    context "#search method" do
      subject { ArtistURL }

      should "work" do
        @bkub = create(:artist, name: "bkub", is_deleted: false, url_string: "https://bkub.com")
        @masao = create(:artist, name: "masao", is_deleted: true, url_string: "-https://masao.com")
        @bkub_url = @bkub.urls.first
        @masao_url = @masao.urls.first

        assert_search_equals([@bkub_url], is_active: true)
        assert_search_equals([@bkub_url], artist: { name: "bkub" })

        assert_search_equals([@bkub_url], url_matches: "*bkub*")
        assert_search_equals([@bkub_url], url_matches: "/^https?://bkub\.com$/")

        assert_search_equals([@bkub_url], normalized_url_matches: "*bkub*")
        assert_search_equals([@bkub_url], normalized_url_matches: "/^https?://bkub\.com/$/")
        assert_search_equals([@bkub_url], normalized_url_matches: "https://bkub.com")

        assert_search_equals([@bkub_url], url: "https://bkub.com")
        assert_search_equals([@bkub_url], url_eq: "https://bkub.com")
        assert_search_equals([@bkub_url], url_not_eq: "https://masao.com")
        assert_search_equals([@bkub_url], url_like: "*bkub*")
        assert_search_equals([@bkub_url], url_ilike: "*BKUB*")
        assert_search_equals([@bkub_url], url_not_like: "*masao*")
        assert_search_equals([@bkub_url], url_not_ilike: "*MASAO*")
        assert_search_equals([@bkub_url], url_regex: "bkub")
        assert_search_equals([@bkub_url], url_not_regex: "masao")
      end
    end
  end
end
