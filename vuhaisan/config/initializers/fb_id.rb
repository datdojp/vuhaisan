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

def get_search_criteria(keyword, separator=',', data_field=:data, flattened_data=:flattened_data)
  if !keyword || keyword.length == 0
    return {}
  end

  tokens = keyword.split separator
  and_criteria = []
  tokens.each do |t|
    regexp = eval "/.*#{Regexp.quote t.strip}.*/i"
    and_criteria << { "$or" => [{data_field => regexp}, {flattened_data => regexp}] }
  end
  { "$and" => and_criteria }
end
