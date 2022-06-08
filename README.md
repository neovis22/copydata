# Copydata Class
WM_COPYDATA 메시지를 이용한 프로세스간 데이터 전달 라이브러리

## Installation

#### 필수 라이브러리
- [json](https://github.com/neovis22/json)

> 아래 방법으로 설치시 함께 설치됩니다.

### 오토핫키 스크립트로 설치하는 방법
아래 두가지 방법중 하나를 선택하여 설치하세요. 먼저 [git](https://git-scm.com/download/win)이 설치되어 있어야 합니다.

#### 표준 라이브러리에 설치
```ahk
RunWait % comspec " /c " "
(join& ltrim
    git clone https://github.com/neovis22/copydata.git
    git clone https://github.com/neovis22/json.git
)", % a_ahkPath "\..\Lib"
```

#### 로컬 라이브러리에 설치
```ahk
RunWait % comspec " /c " "
(join& ltrim
    git clone https://github.com/neovis22/copydata.git Lib/copydata
    git clone https://github.com/neovis22/json.git Lib/json
)"
```

사용할 스크립트에 아래 코드를 추가하세요.
```ahk
#Include <copydata\copydata>
```

## Usage

아래 예제에서 `hwnd`은 대상 프로세스의 핸들입니다.

#### 데이터 보내기
```ahk
copydata.send(hwnd, "보내는 문자열") ; 문자열
copydata.send(hwnd, ["사과", "바나나"]) ; 객체
copydata.send(hwnd, ptr, length) ; 버퍼
```

#### 데이터 받기
```ahk
copydata.onReceive("onCopyData")

onCopyData(hwnd, type, data) {
    switch (type) {
        case "Buffer":
            MsgBox % StrGet(data.ptr, data.length)
        case "String":
            MsgBox % data
        case "Object":
            MsgBox % json_pretty(data)
    }
}
```

#### 함수 호출
```ahk
copydata.timeout := 0 ; 무제한 대기

; 함수가 호출되고 결과값이 반환될때까지 기다립니다
res := copydata.call(hwnd, "DllCall", "MessageBox"
    , "ptr",0, "str","Yes or No", "str","~에서 보냄", "uint",0x4) ; MB_YESNO
MsgBox % "버튼: " (res == 6 ? "Yes" : "No") ; IDYES

; 응답을 기다리지 않고 바로 넘어갑니다
res := copydata.postCall(hwnd, "DllCall", "MessageBox"
    , "ptr",0, "str","Yes or No", "str","~에서 보냄", "uint",0x4) ; MB_YESNO
MsgBox
```

`call`, `gosub` 함수는 `copydata.timeout`에 설정된 대기시간을 초과할 경우 예외를 던집니다.

#### 프로세스간 데이터를 주고받기위한 준비 과정
```ahk
; A 프로그램
Run B.exe /hwnd %a_scriptHwnd%
while (!hwnd)
    Sleep 10
MsgBox % "B hwnd: " hwnd
```

```ahk
; B 프로그램
options := []
for i, v in a_args {
    if (SubStr(v, 1, 1) == "/")
        key := SubStr(v, 2)
    else if (key)
        options[key] := v, key := ""
}
if (!options.hwnd)
    exitapp
copydata.setVar(options.hwnd, "hwnd", a_scriptHwnd)
MsgBox % "A hwnd: " options.hwnd
```
대상 프로그램을 실행시 커맨드라인으로 `a_scriptHwnd` 전달후 응답을 기다린 후 실행된 프로세스의 핸들값을 받아 각각 상대 프로세스의 핸들을 받는 과정입니다.

커맨드라인을 확인하여 스스로를 복제한 프로그램을 실행하는 응용도 가능합니다.

## Methods
- `copydata.send(hwnd, value)` 문자열 혹은 객체 전송
- `copydata.send(hwnd, ptr, length)` 버퍼 전송
- `copydata.call(hwnd, func, args*)` 함수를 호출하며 리턴값 대기
- `copydata.postCall(hwnd, func, args*)` 대기하지 않고 함수를 호출
- `copydata.goto(hwnd, label)` 레이블을 호출하며 현재 쓰래드를 정지
- `copydata.gosub(hwnd, label)` 레이블 호출
- `copydata.setVar(hwnd, var, value)`
- `copydata.getVar(hwnd, var)`
- `copydata.onReceive(callback, addRemove=1)`
    - `callback(hSender, type, data)`
        - `type` `"Buffer"` | `"String"` | `"Object"`

## Properties
- `copydata.timeout` `call`, `gosub` 호출시 기다리는 시간(초), `0`은 무제한

## Contact
[카카오톡 오픈 프로필](https://open.kakao.com/me/neovis)
