module Hermes
  class Phone

    attr_accessor :country, :number

    CODE_LENGTH_RANGE_BY_COUNTRY_CODE = {
      "ca" => 5..6,
      "uk" => 5..5,
      "us" => 5..6,
    }

    COUNTRIES = {
      :af => ['+93',    'Afghanistan'],
      :al => ['+355',   'Albania'],
      :dz => ['+213',   'Algeria'],
      :as => ['+1684',  'American Samoa', :ws],
      :ad => ['+376',   'Andorra'],
      :ao => ['+244',   'Angola'],
      :ai => ['+1264',  'Anguilla'],
      :ag => ['+1268',  'Antigua and Barbuda'],
      :ar => ['+54',    'Argentina'],
      :am => ['+374',   'Armenia'],
      :aw => ['+297',   'Aruba'],
      :au => ['+61',    'Australia/Cocos/Christmas Island'],
      :at => ['+43',    'Austria'],
      :az => ['+994',   'Azerbaijan'],
      :bs => ['+1',     'Bahamas'],
      :bh => ['+973',   'Bahrain'],
      :bd => ['+880',   'Bangladesh'],
      :bb => ['+1246',  'Barbados'],
      :by => ['+375',   'Belarus'],
      :be => ['+32',    'Belgium'],
      :bz => ['+501',   'Belize'],
      :bj => ['+229',   'Benin'],
      :bm => ['+1441',  'Bermuda'],
      :bo => ['+591',   'Bolivia'],
      :ba => ['+387',   'Bosnia and Herzegovina'],
      :bw => ['+267',   'Botswana'],
      :br => ['+55',    'Brazil'],
      :bn => ['+673',   'Brunei'],
      :bg => ['+359',   'Bulgaria'],
      :bf => ['+226',   'Burkina Faso'],
      :bi => ['+257',   'Burundi'],
      :kh => ['+855',   'Cambodia'],
      :cm => ['+237',   'Cameroon'],
      :ca => ['+1',     'Canada'],
      :cv => ['+238',   'Cape Verde'],
      :ky => ['+1345',  'Cayman Islands'],
      :cf => ['+236',   'Central Africa'],
      :td => ['+235',   'Chad'],
      :cl => ['+56',    'Chile'],
      :cn => ['+86',    'China'],
      :co => ['+57',    'Colombia'],
      :km => ['+269',   'Comoros'],
      :cg => ['+242',   'Congo'],
      :cd => ['+243',   'Congo, Dem Rep'],
      :cr => ['+506',   'Costa Rica'],
      :hr => ['+385',   'Croatia'],
      :cy => ['+357',   'Cyprus'],
      :cz => ['+420',   'Czech Republic'],
      :dk => ['+45',    'Denmark'],
      :dj => ['+253',   'Djibouti'],
      :dm => ['+1767',  'Dominica'],
      :do => ['+1809',  'Dominican Republic'],
      :eg => ['+20',    'Egypt'],
      :sv => ['+503',   'El Salvador'],
      :gq => ['+240',   'Equatorial Guinea'],
      :ee => ['+372',   'Estonia'],
      :et => ['+251',   'Ethiopia'],
      :fo => ['+298',   'Faroe Islands'],
      :fj => ['+679',   'Fiji'],
      :fi => ['+358',   'Finland/Aland Islands'],
      :fr => ['+33',    'France'],
      :gf => ['+594',   'French Guiana'],
      :pf => ['+689',   'French Polynesia'],
      :ga => ['+241',   'Gabon'],
      :gm => ['+220',   'Gambia'],
      :ge => ['+995',   'Georgia'],
      :de => ['+49',    'Germany'],
      :gh => ['+233',   'Ghana'],
      :gi => ['+350',   'Gibraltar'],
      :gr => ['+30',    'Greece'],
      :gl => ['+299',   'Greenland'],
      :gd => ['+1473',  'Grenada'],
      :gp => ['+590',   'Guadeloupe'],
      :gu => ['+1671',  'Guam'],
      :gt => ['+502',   'Guatemala'],
      :gn => ['+224',   'Guinea'],
      :gy => ['+592',   'Guyana'],
      :ht => ['+509',   'Haiti'],
      :hn => ['+504',   'Honduras'],
      :hk => ['+852',   'Hong Kong'],
      :hu => ['+36',    'Hungary'],
      :is => ['+354',   'Iceland'],
      :in => ['+91',    'India'],
      :id => ['+62',    'Indonesia'],
      :ir => ['+98',    'Iran'],
      :iq => ['+964',   'Iraq'],
      :ie => ['+353',   'Ireland'],
      :il => ['+972',   'Israel'],
      :it => ['+39',    'Italy'],
      :jm => ['+1876',  'Jamaica'],
      :jp => ['+81',    'Japan'],
      :jo => ['+962',   'Jordan'],
      :ke => ['+254',   'Kenya'],
      :kr => ['+82',    'Korea, Republic of'],
      :kw => ['+965',   'Kuwait'],
      :kg => ['+996',   'Kyrgyzstan'],
      :la => ['+856',   'Laos'],
      :lv => ['+371',   'Latvia'],
      :lb => ['+961',   'Lebanon'],
      :ls => ['+266',   'Lesotho'],
      :lr => ['+231',   'Liberia'],
      :ly => ['+218',   'Libya'],
      :li => ['+423',   'Liechtenstein'],
      :lt => ['+370',   'Lithuania'],
      :lu => ['+352',   'Luxembourg'],
      :mo => ['+853',   'Macao'],
      :mk => ['+389',   'Macedonia'],
      :mg => ['+261',   'Madagascar'],
      :mw => ['+265',   'Malawi'],
      :my => ['+60',    'Malaysia'],
      :mv => ['+960',   'Maldives'],
      :ml => ['+223',   'Mali'],
      :mt => ['+356',   'Malta'],
      :mq => ['+596',   'Martinique'],
      :mr => ['+222',   'Mauritania'],
      :mu => ['+230',   'Mauritius'],
      :mx => ['+52',    'Mexico'],
      :mc => ['+377',   'Monaco'],
      :mn => ['+976',   'Mongolia'],
      :me => ['+382',   'Montenegro'],
      :ms => ['+1664',  'Montserrat'],
      :ma => ['+212',   'Morocco/Western Sahara'],
      :mz => ['+258',   'Mozambique'],
      :na => ['+264',   'Namibia'],
      :np => ['+977',   'Nepal'],
      :nl => ['+31',    'Netherlands'],
      :nz => ['+64',    'New Zealand'],
      :ni => ['+505',   'Nicaragua'],
      :ne => ['+227',   'Niger'],
      :ng => ['+234',   'Nigeria'],
      :no => ['+47',    'Norway'],
      :om => ['+968',   'Oman'],
      :pk => ['+92',    'Pakistan'],
      :ps => ['+970',   'Palestinian Territory'],
      :pa => ['+507',   'Panama'],
      :py => ['+595',   'Paraguay'],
      :pe => ['+51',    'Peru'],
      :ph => ['+63',    'Philippines'],
      :pl => ['+48',    'Poland'],
      :pt => ['+351',   'Portugal'],
      :pr => ['+1',     'Puerto Rico'],
      :qa => ['+974',   'Qatar'],
      :re => ['+262',   'Reunion/Mayotte'],
      :ro => ['+40',    'Romania'],
      :ru => ['+7',     'Russia/Kazakhstan'],
      :rw => ['+250',   'Rwanda'],
      :ws => ['+685',   'Samoa'],
      :sm => ['+378',   'San Marino'],
      :sa => ['+966',   'Saudi Arabia'],
      :sn => ['+221',   'Senegal'],
      :rs => ['+381',   'Serbia'],
      :sc => ['+248',   'Seychelles'],
      :sl => ['+232',   'Sierra Leone'],
      :sg => ['+65',    'Singapore'],
      :sk => ['+421',   'Slovakia'],
      :si => ['+386',   'Slovenia'],
      :za => ['+27',    'South Africa'],
      :es => ['+34',    'Spain'],
      :lk => ['+94',    'Sri Lanka'],
      :kn => ['+1869',  'St Kitts and Nevis'],
      :lc => ['+1758',  'St Lucia'],
      :vc => ['+1784',  'St Vincent Grenadines'],
      :sd => ['+249',   'Sudan'],
      :sr => ['+597',   'Suriname'],
      :sz => ['+268',   'Swaziland'],
      :se => ['+46',    'Sweden'],
      :ch => ['+41',    'Switzerland'],
      :sy => ['+963',   'Syria'],
      :tw => ['+886',   'Taiwan'],
      :tj => ['+992',   'Tajikistan'],
      :tz => ['+255',   'Tanzania'],
      :th => ['+66',    'Thailand'],
      :tg => ['+228',   'Togo'],
      :to => ['+676',   'Tonga'],
      :tt => ['+1868',  'Trinidad and Tobago'],
      :tn => ['+216',   'Tunisia'],
      :tr => ['+90',    'Turkey'],
      :tc => ['+1649',  'Turks and Caicos Islands'],
      :ug => ['+256',   'Uganda'],
      :ua => ['+380',   'Ukraine'],
      :ae => ['+971',   'United Arab Emirates'],
      :gb => ['+44',    'United Kingdom'],
      :us => ['+1',     'United States'],
      :uy => ['+598',   'Uruguay'],
      :uz => ['+998',   'Uzbekistan'],
      :ve => ['+58',    'Venezuela'],
      :vn => ['+84',    'Vietnam'],
      :vg => ['+1284',  'Virgin Islands, British'],
      :vi => ['+1340',  'Virgin Islands, U.S.'],
      :ye => ['+967',   'Yemen'],
      :zm => ['+260',   'Zambia'],
      :zw => ['+263',   'Zimbabwe']
    }.with_indifferent_access

    def ==(other_phone)
      self.country == other_phone.country && self.number == other_phone.number
    end

    def to_s
      self.full_number
    end

    def initialize(country, number)
      # we may have a fully qualified number
      # so try to strip the country code from the front
      @country = country
      @number = number.try(:gsub, country_prefix, '')
    end

    def country_prefix
      self.class.prefix_for_country(@country)
    end

    def country_name
      self.class.name_for_country(@country)
    end

    def full_number
      if self.short_code?
        self.number
      else
        self.class.prefix_for_country(self.country) + self.number
      end
    end

    def short_code?
      !!CODE_LENGTH_RANGE_BY_COUNTRY_CODE[self.country].try(:include?, self.number.length)
    end

    class << self
      def countries
        COUNTRIES
      end

      def prefix_for_country(country)
        country = country.to_s.downcase
        return COUNTRIES[country][0] unless COUNTRIES[country].nil? || COUNTRIES[country][0].nil?
        return nil
      end

      def name_for_country(country)
        country = country.to_s.downcase
        return COUNTRIES[country][1] unless COUNTRIES[country].nil? || COUNTRIES[country][1].nil?
        return nil
      end

      def country_by_prefix(prefix)
        prefix = prefix.gsub(/\+/, '')
        prefix_regex = /^\+.#{prefix}$/

        COUNTRIES.each do |code, prop|
          return code if prefix.regex =~ prop[0]
        end
      end

      def code_for_select_option(select_option)
        COUNTRIES.each do |code, prop|
          return code if select_option == select_option_for_country(code)
        end
      end

      def select_option_for_country(country)
        return "#{self.name_for_country(country)} (#{self.prefix_for_country(country)})" unless self.name_for_country(country).nil? || self.prefix_for_country(country).nil?
        return nil
      end

      def possible_full_number_extractions(full_number)
        # this will come inbound as something like '16498675309' or '+16498675309'
        # and we need to extract the following as possible list of results
        # [
        #   {
        #     country: :us,
        #     number: '6498675309'
        #   },
        #   {
        #     country: :ca,
        #     number: '6498675309',
        #   },
        #   {
        #     country: :tc,
        #     number: '8675309'
        #   }
        # ]

        results = []
        countries.each do |country_code, (prefix, name)|
          # try with the plus, and with the plus trimmed
          full = prefix
          short = prefix[1..-1]

          # see if the number starts with either the full or the short prefix
          has_full = full_number.start_with?(full)
          has_short = full_number.start_with?(short)

          # if either match, do the extraction
          if has_full
            results << Hermes::Phone.new(country_code, full_number[full.length..-1])
          elsif has_short
            results << Hermes::Phone.new(country_code, full_number[short.length..-1])
          end
        end

        return results
      end
    end
  end
end
