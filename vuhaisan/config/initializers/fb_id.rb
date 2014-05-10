# encoding: UTF-8

def get_fb_id(request)
  if request.host == "localhost"
    "528436213933673" # dev
  else
    "282232941951912" # production
  end
end

def get_fanpage
  "https://www.facebook.com/pages/Parivn/228045140567855"
end

VTC_PAY_BASE_URL = "https://pay.vtc.vn/cong-thanh-toan/checkout.html"
VTC_PAY_WEBSITE_ID = "790"
VTC_PAY_PAYMENT_METHOD = 1
VTC_PAY_RECEIVER_ACC = "0987002799"
VTC_PAY_SECRET = "dadaocongsanBANNUOC123"
VTC_PARAM_EXTEND = ""
VTC_RESULT_URL = "/payment/vtc"

VIETNAMESE_CHARS = [
  "à","á","ạ","ả","ã","â","ầ","ấ","ậ","ẩ","ẫ","ă",
  "ằ","ắ","ặ","ẳ","ẵ","è","é","ẹ","ẻ","ẽ","ê","ề",
  "ế","ệ","ể","ễ",
  "ì","í","ị","ỉ","ĩ",
  "ò","ó","ọ","ỏ","õ","ô","ồ","ố","ộ","ổ","ỗ","ơ",
  "ờ","ớ","ợ","ở","ỡ",
  "ù","ú","ụ","ủ","ũ","ư","ừ","ứ","ự","ử","ữ",
  "ỳ","ý","ỵ","ỷ","ỹ",
  "đ",
  "À","Á","Ạ","Ả","Ã","Â","Ầ","Ấ","Ậ","Ẩ","Ẫ","Ă",
  "Ằ","Ắ","Ặ","Ẳ","Ẵ",
  "È","É","Ẹ","Ẻ","Ẽ","Ê","Ề","Ế","Ệ","Ể","Ễ",
  "Ì","Í","Ị","Ỉ","Ĩ",
  "Ò","Ó","Ọ","Ỏ","Õ","Ô","Ồ","Ố","Ộ","Ổ","Ỗ","Ơ",
  "Ờ","Ớ","Ợ","Ở","Ỡ",
  "Ù","Ú","Ụ","Ủ","Ũ","Ư","Ừ","Ứ","Ự","Ử","Ữ",
  "Ỳ","Ý","Ỵ","Ỷ","Ỹ",
  "Đ"
]

FLATTENED_VIETNAMESE_CHARS = [
  "a","a","a","a","a","a","a","a","a","a","a",
  "a","a","a","a","a","a",
  "e","e","e","e","e","e","e","e","e","e","e",
  "i","i","i","i","i",
  "o","o","o","o","o","o","o","o","o","o","o","o",
  "o","o","o","o","o",
  "u","u","u","u","u","u","u","u","u","u","u",
  "y","y","y","y","y",
  "d",
  "A","A","A","A","A","A","A","A","A","A","A","A",
  "A","A","A","A","A",
  "E","E","E","E","E","E","E","E","E","E","E",
  "I","I","I","I","I",
  "O","O","O","O","O","O","O","O","O","O","O","O",
  "O","O","O","O","O",
  "U","U","U","U","U","U","U","U","U","U","U",
  "Y","Y","Y","Y","Y",
  "D"
]

def flatten_vietnamese(s)
  if !s or s.length == 0
    return s
  end
  chars = s.split ""
  ret = []
  chars.each do |c|
    index = VIETNAMESE_CHARS.find_index c
    if index
      ret << FLATTENED_VIETNAMESE_CHARS[index]
    else
      ret << c
    end
  end

  ret.join ""
end

def get_search_data(obj, fields)
  arr = []
  fields.each do |f|
    v = eval "obj.#{f}"
    arr << v if v
  end
  data = arr.join "\n"
  [data, flatten_vietnamese(data)]
end

def get_search_criteria(
    keyword,
    search_price=false,
    separator=',',
    data_field=:data,
    flattened_data=:flattened_data)

  if !keyword || keyword.length == 0
    return {}
  end

  tokens = keyword.split separator
  and_criteria = []
  tokens.each do |t|
    t = t.strip
    if search_price && (
        /^\d+-$/.match(t) ||
        /^-\d+$/.match(t) ||
        /^\d+-\d+$/.match(t) )
      splitted = t.split '-'
      if splitted.length > 0
        from = splitted[0]
        if from.length > 0
          and_criteria << { price: {"$gte" => Integer(from)} }
        end
      end
      if splitted.length > 1
        to = splitted[1]
        if to.length > 0
          and_criteria << { price: {"$lte" => Integer(to)} }
        end
      end
    else
      regexp = eval "/.*#{Regexp.quote t}.*/i"
      and_criteria << { "$or" => [{data_field => regexp}, {flattened_data => regexp}] }
    end
  end
  { "$and" => and_criteria }
end

SHIP_COST = 30 * 1000

LOCATION_DATA = {
  "An Giang" => SHIP_COST,
  "Bà Rịa-Vũng Tàu" => SHIP_COST,
  "Bạc Liêu" => SHIP_COST,
  "Bắc Kạn" => SHIP_COST,
  "Bắc Giang" => SHIP_COST,
  "Bắc Ninh" => SHIP_COST,
  "Bến Tre" => SHIP_COST,
  "Bình Dương" => SHIP_COST,
  "Bình Định" => SHIP_COST,
  "Bình Phước" => SHIP_COST,
  "Bình Thuận" => SHIP_COST,
  "Cà Mau" => SHIP_COST,
  "Cao Bằng" => SHIP_COST,
  "Cần Thơ" => SHIP_COST,
  "Đà Nẵng" => SHIP_COST,
  "Đắk Lắk" => SHIP_COST,
  "Đăk Nông" => SHIP_COST,
  "Điện Biên" => SHIP_COST,
  "Đồng Nai" => SHIP_COST,
  "Đồng Tháp" => SHIP_COST,
  "Gia Lai" => SHIP_COST,
  "Hà Giang" => SHIP_COST,
  "Hà Nam" => SHIP_COST,
  "Hà Nội" => SHIP_COST,
  "Hà Tĩnh" => SHIP_COST,
  "Hải Dương" => SHIP_COST,
  "Hải Phòng" => SHIP_COST,
  "Hậu Giang" => SHIP_COST,
  "Hòa Bình" => SHIP_COST,
  "TP Hồ Chí Minh" => {
    "Quận 1" => 0,
    "Quận 2" => 0,
    "Quận 3" => 0,
    "Quận 4" => 0,
    "Quận 5" => 0,
    "Quận 6" => SHIP_COST,
    "Quận 7" => 0,
    "Quận 8" => SHIP_COST,
    "Quận 9" => SHIP_COST,
    "Quận 10" => 0,
    "Quận 11" => 0,
    "Quận 12" => SHIP_COST,
    "Thủ Đức" => SHIP_COST,
    "Tân Phú" => 0,
    "Tân Bình" => 0,
    "Phú Nhuận" => 0,
    "Gò Vấp" => 0,
    "Bình Thạnh" => 0,
    "Bình Tân" => SHIP_COST,
    "Bình Chánh" => SHIP_COST,
    "Cần Giờ" => SHIP_COST,
    "Củ Chi" => SHIP_COST,
    "Hóc Môn" => SHIP_COST,
    "Nhà Bè" => SHIP_COST
  },
  "Hưng Yên" => SHIP_COST,
  "Khánh Hòa" => SHIP_COST,
  "Kiên Giang" => SHIP_COST,
  "Kon Tum" => SHIP_COST,
  "Lai Châu" => SHIP_COST,
  "Lâm Đồng" => SHIP_COST,
  "Lạng Sơn" => SHIP_COST,
  "Lào Cai" => SHIP_COST,
  "Long An" => SHIP_COST,
  "Nam Định" => SHIP_COST,
  "Nghệ An" => SHIP_COST,
  "Ninh Bình" => SHIP_COST,
  "Ninh Thuận" => SHIP_COST,
  "Phú Thọ" => SHIP_COST,
  "Phú Yên" => SHIP_COST,
  "Quảng Bình" => SHIP_COST,
  "Quảng Nam" => SHIP_COST,
  "Quảng Ngãi" => SHIP_COST,
  "Quảng Ninh" => SHIP_COST,
  "Quảng Trị" => SHIP_COST,
  "Sóc Trăng" => SHIP_COST,
  "Sơn La" => SHIP_COST,
  "Tây Ninh" => SHIP_COST,
  "Thái Bình" => SHIP_COST,
  "Thái Nguyên" => SHIP_COST,
  "Thanh Hóa" => SHIP_COST,
  "Thừa Thiên-Huế" => SHIP_COST,
  "Tiền Giang" => SHIP_COST,
  "Trà Vinh" => SHIP_COST,
  "Tuyên Quang" => SHIP_COST,
  "Vĩnh Long" => SHIP_COST,
  "Vĩnh Phúc" => SHIP_COST,
  "Yên Bái" => SHIP_COST
}

def get_location_select(data)
  ret = [[nil, nil]]
  data.keys.each do |p|
    ret << [p, p]
  end
  ret
end

def format_currency(amount)
  number_to_currency amount, unit: "", precision: 0
end

def get_request_url()
  "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
end