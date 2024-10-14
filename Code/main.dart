import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PomodoroTimer {
  int workDuration = 25 * 60; // 25분을 초로 변환
  int shortBreakDuration = 5 * 60; // 5분을 초로 변환
  int longBreakDuration = 15 * 60; // 15분을 초로 변환
  int sessionCount = 0; // 작업 세션 카운트
  bool isWorking = true; // 현재 작업 중인지 여부
  bool isPaused = false; // 일시정지 여부
  Timer? timer; // 타이머 객체

  void startPomodoro() {
    if (timer != null && timer!.isActive) {
      _printMessage("타이머가 이미 실행 중입니다.");
      return;
    }

    _printMessage("Pomodoro 타이머를 시작합니다.");
    _startTimer();
  }

  void _startTimer() {
    _displayTimer(); // 타이머 시작 시 즉시 표시
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (!isPaused) {
        if (isWorking && workDuration > 0) {
          workDuration--;
        } else if (!isWorking && shortBreakDuration > 0) {
          shortBreakDuration--;
        } else {
          if (isWorking) {
            sessionCount++;
            isWorking = false;

            // 4회차마다 긴 휴식 (15분), 그 외는 짧은 휴식 (5분)
            shortBreakDuration = (sessionCount % 4 == 0) ? longBreakDuration : 5 * 60;
            _printMessage("\n작업 시간이 종료되었습니다. 휴식 시간을 시작합니다.");
          } else {
            isWorking = true;
            workDuration = 25 * 60;
            _printMessage("\n휴식 시간이 종료되었습니다. 작업 시간을 시작합니다.");
          }

          if (sessionCount % 4 == 0) {
            sessionCount = 0; // 5회차가 되면 1회차처럼 반복
          }
        }
      }
      _displayTimer();
    });
  }

  void stopPomodoro() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
      isPaused = false;
      isWorking = true;
      workDuration = 25 * 60;
      shortBreakDuration = 5 * 60;
      _printMessage("\nPomodoro 타이머가 중지되었습니다.");
      _clearTimerDisplay();
    } else {
      _printMessage("타이머가 실행 중이 아닙니다.");
    }
  }

  void pausePomodoro() {
    if (timer != null && timer!.isActive && !isPaused) {
      isPaused = true;
      _printMessage("\nPomodoro 타이머가 일시정지되었습니다.");
    } else {
      _printMessage("타이머가 실행 중이 아니거나 이미 일시정지 상태입니다.");
    }
  }

  void resumePomodoro() {
    if (timer != null && timer!.isActive && isPaused) {
      isPaused = false;
      _printMessage("\nPomodoro 타이머가 재개되었습니다.");
    } else {
      _printMessage("타이머가 실행 중이 아니거나 일시정지 상태가 아닙니다.");
    }
  }

  String getTimeString(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void showInstructions() {
    _printMessage("""
========================
Pomodoro 타이머 사용법:
1. 'start' 입력: 타이머 시작
2. 'pause' 입력: 타이머 일시정지
3. 'resume' 입력: 타이머 재개
4. 'stop' 입력: 타이머 중지
5. 'exit' 입력: 프로그램 종료
========================
    """);
  }

  void _displayTimer() {
    String status = isWorking ? '작업 시간' : '휴식 시간';
    int time = isWorking ? workDuration : shortBreakDuration;
    String timeString = getTimeString(time);

    // 커서를 타이머 출력 위치로 이동하고 업데이트
    stdout.write('\x1b7'); // 커서 위치 저장
    stdout.write('\x1b[1;1H'); // 커서를 첫 번째 줄로 이동
    stdout.write('\x1b[2K'); // 현재 줄 지우기
    stdout.write('$status: $timeString');
    stdout.write('\x1b8'); // 이전 커서 위치 복원
  }

  void _clearTimerDisplay() {
    // 타이머 출력 지우기
    stdout.write('\x1b7'); // 커서 위치 저장
    stdout.write('\x1b[1;1H'); // 커서를 첫 번째 줄로 이동
    stdout.write('\x1b[2K'); // 현재 줄 지우기
    stdout.write('\x1b8'); // 이전 커서 위치 복원
  }

  void _printMessage(String message) {
    // 메시지를 출력하고 입력 프롬프트를 다시 표시
    stdout.write('\n$message\n> ');
  }
}

void main() {
  PomodoroTimer pomodoroTimer = PomodoroTimer();
  pomodoroTimer.showInstructions();

  stdout.write('> '); // 입력 프롬프트 출력

  // 터미널 에코 및 라인 모드 설정
  stdin.echoMode = true;
  stdin.lineMode = true;

  // 비동기적으로 사용자 입력을 받는 부분
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((input) {
    String command = input.trim().toLowerCase();
    switch (command) {
      case 'start':
        pomodoroTimer.startPomodoro();
        break;
      case 'pause':
        pomodoroTimer.pausePomodoro();
        break;
      case 'resume':
        pomodoroTimer.resumePomodoro();
        break;
      case 'stop':
        pomodoroTimer.stopPomodoro();
        break;
      case 'exit':
        pomodoroTimer.stopPomodoro();
        stdout.write('\n프로그램을 종료합니다.\n');
        exit(0);
        break;
      default:
        stdout.write('\n알 수 없는 명령어입니다. 다시 입력하세요.\n> ');
    }
  });
}
