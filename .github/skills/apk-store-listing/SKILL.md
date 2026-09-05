---
name: apk-store-listing
description: "Dùng khi chuẩn bị thông tin APKPure hoặc store từ project Flutter. Đọc project và cung cấp Type, Categories, content rating, Default Language, Title, Short Description, Description và hướng dẫn Feature Graphic mà không tự bịa thông tin. Mặc định trả lời bằng tiếng Việt; chỉ dùng tiếng Anh khi người dùng yêu cầu."
---

# Thông tin phát hành APK

## Mục đích

Đọc project Flutter trong workspace hiện tại và chuẩn bị thông tin cần thiết để phát hành app lên APKPure. Kết quả phải dựa trên mã nguồn thực tế, không dựa trên tên repository hoặc giả định chung chung.

Các trường bắt buộc:

1. Type
2. Categories
3. Content Rating
4. Default Language
5. Title
6. Short Description
7. Description
8. Feature Graphic 1024x500

Feature Graphic là tài sản hình ảnh. Không được tự tạo hoặc khẳng định hình ảnh đã tồn tại. Chỉ mô tả nội dung nên có và đánh dấu đây là phần cần thực hiện thủ công.

## Nguồn cần kiểm tra

Chỉ đọc đủ phạm vi để xác định tên app và tính năng thực tế. Ưu tiên các nguồn theo thứ tự sau:

1. `pubspec.yaml`
   - mô tả package
   - phiên bản
   - assets
   - dependency liên quan đến notification, lưu trữ, network, analytics, quảng cáo hoặc thanh toán
2. `android/app/src/main/AndroidManifest.xml`
   - application label
   - permission
   - activity và launcher Android
3. `android/app/build.gradle.kts` hoặc `android/app/build.gradle`
   - application ID
   - SDK target
4. `ios/Runner/Info.plist`
   - tên hiển thị trên iOS
   - bundle metadata
5. `lib/main.dart`
   - route
   - provider
   - khởi tạo và cơ chế lưu trữ
6. `lib/views/**`, `lib/widgets/**` và `lib/constants/**`
   - tính năng người dùng nhìn thấy
   - nhãn điều hướng
   - URL chính sách
7. `README.md` và test
   - hành vi dự kiến
   - các luồng được hỗ trợ

Tìm kiếm có mục tiêu các từ khóa như `title`, `label`, `description`, `category`, `notification`, `permission`, `movie`, `tv`, `sport`, `todo`, `calendar`, `game`, `share`, `rate`, `policy`, `analytics`, `ads` và `payment`.

## Quy tắc về bằng chứng

- Chỉ báo cáo các thông tin nhìn thấy trong code hoặc cấu hình.
- Tách riêng thông tin đã xác nhận và đề xuất.
- Không khẳng định app không thu thập dữ liệu chỉ vì chưa thấy code thu thập trong vài file đầu tiên. Cần kiểm tra network client, analytics, quảng cáo, authentication và storage.
- Xem việc gọi API bên thứ ba là xử lý dữ liệu bên ngoài. Xác định tên dịch vụ và ghi trong phần ghi chú.
- Không đưa API key, token, mật khẩu ký app hoặc secret khác vào kết quả.
- Không dùng tên phim, chương trình TV, giải thể thao hoặc thương hiệu trong title nếu project không sở hữu thương hiệu đó.
- Nếu không thể chứng minh một giá trị bắt buộc, ghi `CẦN XÁC NHẬN` và giải thích chủ app cần quyết định điều gì.
- Nội dung phải phù hợp với bản phát hành thực tế. Không quảng cáo tính năng đang tắt, placeholder hoặc chưa hoàn thiện.
- Title nên ngắn để phù hợp giới hạn của store. Ưu tiên tối đa 30 ký tự nếu quy định hiện hành không cho phép dài hơn.
- Short Description cần ngắn gọn, tập trung vào lợi ích và tránh nhồi từ khóa.
- Không đưa các tuyên bố không có bằng chứng như “bảo mật”, “tốt nhất”, “chính thức”, “không thu thập dữ liệu” hoặc “hoạt động offline hoàn toàn”.

## Hướng dẫn phân loại

### Type

Phân loại theo mục đích chính của sản phẩm, không theo một tính năng phụ:

- Dùng `Application` khi mục đích chính là productivity, tiện ích, khám phá nội dung, giáo dục hoặc workflow app thông thường.
- Chỉ dùng `Game` khi gameplay là trải nghiệm chính và phần lớn điều hướng dẫn đến game.
- Nếu project kết hợp cả hai, giải thích quyết định trong một câu.

### Categories

Chọn một category chính và tối đa một category phụ dựa trên tính năng thực tế. Với app có workflow chính là quản lý task, calendar và kế hoạch thể thao, đề xuất:

- Chính: `Productivity`
- Phụ: `Sports`

Chỉ thêm `Entertainment` khi tính năng khám phá phim/TV là một phần đáng kể đối với người dùng. Không liệt kê mọi category có thể dùng.

### Content Rating

Đánh giá thận trọng dựa trên nội dung và chức năng nhìn thấy:

- `Everyone` / `3+` chỉ phù hợp khi không có ngôn ngữ tục, nội dung tình dục, bạo lực thực tế, cờ bạc, nội dung công khai do người dùng tạo hoặc media trưởng thành không giới hạn.
- Tính năng tìm kiếm phim và TV có thể cần mức rating cao hơn hoặc rating riêng của store nếu catalog trả về nội dung dành cho người trưởng thành. Phải ghi rõ cần kiểm tra thủ công.
- Mini-game sút phạt thể thao không tự nó yêu cầu rating dành cho người trưởng thành.
- Nếu project hiển thị media từ xa nhưng không biết trước độ tuổi, đưa ra đề xuất thận trọng và ghi mục trong bảng câu hỏi store cần xác nhận thủ công.

### Default Language

Dùng ngôn ngữ của UI nhìn thấy, không dùng locale chỉ phục vụ format ngày tháng. Kiểm tra label trong screen và widget. Nếu UI chủ yếu là tiếng Anh, đề xuất `English`. Nếu có nhiều ngôn ngữ nhưng không có bộ chọn ngôn ngữ, báo cáo ngôn ngữ chiếm ưu thế và ghi chú rằng app chưa có localization hoàn chỉnh.

## Định dạng kết quả

Luôn trả về đúng cấu trúc sau bằng Markdown. Mặc định viết nội dung bằng tiếng Việt; chỉ tạo phần tiếng Anh khi người dùng yêu cầu:

```md
# Thông tin APKPure

## 1. Type

- Giá trị:
- Bằng chứng:
- Mức độ chắc chắn:

## 2. Categories

- Chính:
- Phụ:
- Bằng chứng:
- Mức độ chắc chắn:

## 3. Content Rating

- Giá trị đề xuất:
- Lý do:
- Cần xác nhận thủ công:
- Mức độ chắc chắn:

## 4. Default Language

- Giá trị:
- Bằng chứng:
- Mức độ chắc chắn:

## 5. Title

- Giá trị:
- Nguồn:
- Ghi chú:

## 6. Short Description

- Tiếng Việt:
- Tiếng Anh: chỉ điền khi người dùng yêu cầu tiếng Anh
- Kiểm tra số ký tự:

## 7. Description

### Tiếng Việt

### Tiếng Anh

Chỉ tạo phần này khi người dùng yêu cầu tiếng Anh.

## 8. Feature Graphic 1024x500

- Trạng thái: Cần tạo thủ công
- Nội dung đề xuất:
- Nội dung nên đặt trên hình:
- Cần tránh:
- Yêu cầu xuất file:

## Ghi chú phát hành

- Phiên bản:
- Android application ID:
- iOS bundle ID:
- URL chính sách quyền riêng tư:
- Dịch vụ bên thứ ba:
- Permission liên quan đến kiểm duyệt store:
- Các mục vẫn cần chủ app xác nhận:
```

Với mỗi trường, ưu tiên đưa giá trị trực tiếp rồi đến bằng chứng ngắn. Không trả về một bài mô tả dài về toàn bộ repository.

## Thông tin nền của project hiện tại

Khi đọc repository này, implementation hiện tại gợi ý các giá trị ban đầu sau. Vẫn phải kiểm tra lại sau mỗi thay đổi code:

- Title: `TodoList Sports`
- Type: `Application`
- Category chính: `Productivity`
- Category phụ: `Sports`
- Category có thể thêm: `Entertainment`
- Ngôn ngữ mặc định: `English`
- Tính năng chính: quản lý task, lập lịch calendar, nhắc việc cục bộ, theo dõi sự kiện thể thao, thống kê hoàn thành, khám phá phim và TV, chia sẻ và mini-game sút phạt
- Phiên bản hiện tại trong `pubspec.yaml`: `1.0.0+1`
- Android application ID hiện tại: `com.example.mv2629`; phải đánh dấu là blocker phát hành vì đây là ID mặc định/mẫu
- Android label hiện tại: `TodoList Sports`
- Tên hiển thị iOS hiện vẫn là `Mv2629`; phải đánh dấu cần sửa trước khi phát hành iOS
- URL privacy policy tìm thấy trong cấu hình project: `https://nghia-policy.web.app/apps/todo-list-sport/privacy-policy`
- Nội dung policy trong app hiện mô tả đây là bản demo; phải đánh dấu cần kiểm tra trước khi phát hành
- TMDB được dùng cho dữ liệu phim và TV; không được ám chỉ toàn bộ nội dung thuộc quyền sở hữu của publisher app
- Android có permission cho local notification; phải ghi trong ghi chú phát hành

Không sao chép secret từ `lib/constants/app_config.dart` vào kết quả. Chỉ nêu tên dịch vụ, ví dụ TMDB.

## Checklist Feature Graphic

Chủ app tự thực hiện phần này. Đề xuất ảnh PNG hoặc JPG kích thước 1024x500 có:

- title hoặc logo của app
- hình ảnh thể hiện rõ việc lập kế hoạch task và lịch thể thao
- độ tương phản tốt, chữ vẫn đọc được ở kích thước nhỏ
- không có store badge, thứ hạng hoặc tuyên bố gây hiểu nhầm
- không dùng artwork phim có bản quyền nếu chưa có quyền sử dụng
- không chứa private key, URL, hoặc label dùng cho test

Kết quả cuối cùng phải nói rõ graphic không được skill này tạo ra và cần được upload riêng.
