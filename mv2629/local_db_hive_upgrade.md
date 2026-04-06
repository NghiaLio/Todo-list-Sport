**Báo Cáo Chi Tiết: Nâng Cấp Local Database Hive (Todo)**

**1. Mục tiêu và mức độ đáp ứng**
- Scale tốt với 10k+ records: Đã đáp ứng bằng kiến trúc tách box dữ liệu, index, lookup, meta và cache trong taskTodoImp.dart.
- Query theo date nhanh: Đã đáp ứng bằng date index key dạng yyyymmdd tại taskTodoImp.dart và taskTodoImp.dart.
- Hỗ trợ pagination: Đã đáp ứng qua API phân trang tại taskTodoRepo.dart, taskTodoRepo.dart, và triển khai tại taskTodoImp.dart, taskTodoImp.dart.
- Không scan toàn bộ dữ liệu ở luồng đọc nóng: Đã đáp ứng, completion rate lấy từ counter meta tại taskTodoImp.dart, không duyệt toàn bộ values.
- Có cache layer: Đã đáp ứng với task cache + page cache LRU tại taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart.

**2. Thiết kế kiến trúc dữ liệu**
- Box chính task:
  - taskTodos lưu TaskTodoModel theo key là id.
  - Truy cập qua getter tại taskTodoImp.dart.
- Box lookup:
  - taskTodoDateLookup lưu taskId -> dateKey.
  - Định nghĩa tại taskTodoImp.dart, mở box tại main.dart.
- Box index ngày:
  - taskTodoDateIndex lưu dateKey -> List taskId.
  - Định nghĩa tại taskTodoImp.dart, mở box tại main.dart.
- Box meta:
  - taskTodoMeta lưu all_ids, total_count, completed_count.
  - Định nghĩa key tại taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart, mở box tại main.dart.

**3. API contract mới**
- Bổ sung object phân trang TaskTodoPage với hasNextPage tại taskTodoRepo.dart, taskTodoRepo.dart.
- Bổ sung 2 API:
  - getTasksPaged tại taskTodoRepo.dart.
  - getTasksByDatePaged tại taskTodoRepo.dart.
- Triển khai tương ứng trong service:
  - taskTodoImp.dart
  - taskTodoImp.dart

**4. Phân tích độ phức tạp**
- Add task:
  - Ghi task + update lookup/index/meta + invalidate cache.
  - Chi phí gần O(1), ngoại lệ phần contains trên list id theo ngày/all_ids có thể O(n) theo bucket.
  - Điểm chính: taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart.
- Delete task:
  - Lấy dateKey từ lookup rồi remove theo index/meta.
  - Gần O(1), remove trong list là O(n) theo bucket.
  - Điểm chính: taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart.
- Update task:
  - Nếu đổi ngày thì di chuyển id giữa 2 bucket index.
  - Counter completed đồng bộ delta.
  - Điểm chính: taskTodoImp.dart, taskTodoImp.dart.
- Query completion rate:
  - O(1) từ meta counters.
  - Điểm chính: taskTodoImp.dart.
- Query by date + pagination:
  - Lấy list id theo dateKey rồi cắt trang theo offset.
  - Hydrate đúng pageSize item, không scan toàn bộ box task.
  - Điểm chính: taskTodoImp.dart, taskTodoImp.dart.

**5. Cơ chế migration và tương thích dữ liệu cũ**
- Có bootstrap một lần để rebuild index/meta khi phát hiện lệch dữ liệu.
- Tự xử lý dữ liệu legacy có key Hive khác task.id bằng cách put lại theo id và delete key cũ.
- Điểm chính:
  - Guard bootstrap: taskTodoImp.dart
  - Rebuild index/meta: taskTodoImp.dart
  - Chuẩn hóa key cũ: taskTodoImp.dart

**6. Cache layer**
- Task cache:
  - LinkedHashMap + đẩy key vừa dùng về cuối để mô phỏng LRU.
  - Giới hạn 2000 item tại taskTodoImp.dart, logic tại taskTodoImp.dart.
- Page cache:
  - Cache theo key gồm scope, page, pageSize, order.
  - Giới hạn 256 page tại taskTodoImp.dart, logic tại taskTodoImp.dart, taskTodoImp.dart.
- Invalidate:
  - Clear page cache sau add/update/delete để tránh stale page.
  - Điểm chính: taskTodoImp.dart, taskTodoImp.dart, taskTodoImp.dart.

**7. Rủi ro còn lại và khuyến nghị**
- Rủi ro 1: List id trong index/meta dùng contains/remove nên chưa tuyệt đối O(1) khi bucket quá lớn.
  - Khuyến nghị: Chuyển index sang cấu trúc map id->1 theo ngày, hoặc lưu thêm set-like box để bỏ contains tuyến tính.
- Rủi ro 2: all_ids có thể tăng lớn theo thời gian.
  - Khuyến nghị: Nếu yêu cầu cực lớn hơn 100k, cân nhắc phân vùng theo tháng hoặc dùng cursor theo timestamp thay vì mảng toàn cục.
- Rủi ro 3: Chưa có test tự động cho invariants index.
  - Khuyến nghị: Thêm test cho các bất biến:
    - taskTodos có id thì dateLookup phải có.
    - dateIndex(dateKey) phải chứa đúng id tương ứng.
    - total_count và completed_count khớp dữ liệu thực.
- Rủi ro 4: Bootstrap hiện chạy khi lần đầu chạm repo, có thể tốn thời gian nếu data lớn.
  - Khuyến nghị: Chạy warm-up bootstrap ở màn splash hoặc isolate nền nếu UX cần mượt hơn.

**8. Trạng thái kiểm chứng**
- Đã analyze phần thay đổi chính, không có lỗi mới:
  - taskTodoImp, taskTodoRepo, main.
- Tham chiếu mở box mới ở startup:
  - main.dart
  - main.dart
  - main.dart

**Kết luận**
- Phần nâng cấp này đã đạt đúng yêu cầu kỹ thuật cốt lõi cho dữ liệu 10k+ theo hướng thực dụng với Hive: index theo ngày, pagination, tránh full scan ở read-path nóng, và có cache layer.
- Điểm cần làm tiếp để production-hardening là bộ test consistency + tối ưu thêm cấu trúc index nếu kỳ vọng tăng trưởng rất lớn.