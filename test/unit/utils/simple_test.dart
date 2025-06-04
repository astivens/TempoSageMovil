import "package:flutter_test/flutter_test.dart";
import "package:temposage/core/utils/date_time_helper.dart";

void main() {
  group('DateTimeHelper simple tests', () {
    test("getShortMonth works", () {
      expect(DateTimeHelper.getShortMonth(DateTime(2023, 1, 1)), "Ene");
    });

    test("formatTime works", () {
      expect(DateTimeHelper.formatTime(DateTime(2023, 1, 1, 9, 30)), "09:30");
      expect(DateTimeHelper.formatTime(DateTime(2023, 1, 1, 15, 45)), "15:45");
    });

    test("getDayOfWeekES works", () {
      expect(DateTimeHelper.getDayOfWeekES(DateTime(2023, 1, 2)), "Lunes");
      expect(DateTimeHelper.getDayOfWeekES(DateTime(2023, 1, 8)), "Domingo");
    });
  });
}
