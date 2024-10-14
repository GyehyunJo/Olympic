import 'dart:async';

void main() {
  int workDuration = 25 * 60; // 25분을 초로 변환
  int shortBreakDuration = 5 * 60; // 5분을 초로 변환
  int longBreakDuration = 15 * 60; // 15분을 초로 변환
  int sessionCount = 0; // 작업 세션 카운트
  bool isWorking = true; // 현재 작업 중인지 여부

  void startPomodoro() {
    print("flutter: Pomodoro 타이머를 시작합니다.");
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (workDuration > 0 && isWorking) {
        // 작업 시간 중일 때
        workDuration--;
        print("flutter: ${workDuration ~/ 60}:${(workDuration % 60).toString().padLeft(2, '0')}");
      } else if (!isWorking && shortBreakDuration > 0) {
        // 휴식 시간 중일 때
        shortBreakDuration--;
        print("flutter: 휴식 시간: ${shortBreakDuration ~/ 60}:${(shortBreakDuration % 60).toString().padLeft(2, '0')}");
      } else {
        // 세션 종료 및 상태 전환
        if (isWorking) {
          print("flutter: 작업 시간이 종료되었습니다. 휴식 시간을 시작합니다.");
          sessionCount++;
          isWorking = false;
          shortBreakDuration = (sessionCount % 4 == 0) ? longBreakDuration : 5 * 60; // 4회차마다 긴 휴식
        } else {
          print("flutter: 휴식 시간이 종료되었습니다. 작업 시간을 시작합니다.");
          isWorking = true;
          workDuration = 25 * 60;
        }

        if (sessionCount >= 4) {
          // 4회차 종료 시 타이머를 멈춤
          print("flutter: 4회차 작업이 모두 완료되었습니다.");
          timer.cancel();
        }
      }
    });
  }

  startPomodoro();
}