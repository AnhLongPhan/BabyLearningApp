# BabyLearningApp

BabyLearningApp la ung dung iOS SwiftUI danh cho tre 3-4 tuoi hoc chu cai, so dem va phep cong don gian thong qua cac mini game vui nhon.

Ung dung chay local, chua can backend, dung `AVSpeechSynthesizer` de doc cau hoi va phan hoi bang giong noi. Code duoc to chuc theo huong MVVM de de mo rong them mini game, hinh anh minh hoa, ngon ngu va nguon am thanh trong tuong lai.

## Tinh nang chinh

- Trang chu voi cac mini game hoc tap lon, de bam.
- Hoc chu cai bang bong bong chu cai noi tren man hinh.
- Hoc so qua tro choi tim so dung.
- Dem do vat voi hinh minh hoa va dap an dang bong bong.
- Cong vui trong pham vi 10 voi object minh hoa truc quan.
- Tu dong doc cau hoi khi vao round moi.
- Nut nghe lai de be co the nghe lai cau hoi.
- Phan hoi dung/sai bang giong noi, hieu ung va sticker reward.
- Cai dat ten be, avatar, gioi han chu cai/so/tong phep cong va ngon ngu.
- Luu tien do don gian bang `AppStorage`.

## Kien truc

Du an duoc to chuc theo MVVM:

- `Models/`: cac model hoc tap nhu chu cai, so, cau hoi toan, ngon ngu.
- `Data/`: du lieu mau cho cac bai hoc.
- `Services/`: tang am thanh, hien tai dung `AVSpeechSynthesizer`.
- `ViewModels/`: quan ly logic tung mini game va trang thai round.
- `Views/`: man hinh SwiftUI.
- `Views/Components/`: cac component tai su dung nhu bubble, mascot, reward, audio replay.

## Cong nghe

- SwiftUI
- AVFoundation
- Observation
- AppStorage / UserDefaults
- PhotosUI
- Khong dung thu vien ben ngoai

## Cach chay

1. Mo project trong Xcode:

   ```bash
   open BabyLearningApp.xcodeproj
   ```

2. Chon simulator iPhone, vi du iPhone 11.
3. Bam Run.

App khong can backend hoac asset tuy chinh de chay. Neu chua co anh minh hoa, app se dung emoji/placeholder co san.

## Huong mo rong

- Them asset minh hoa vao `Assets.xcassets` va map qua `imageName`.
- Thay `SpeechAudioProvider` bang provider phat mp3 hoac AI voice.
- Them ngon ngu moi trong `LearningLanguage`.
- Them mini game moi bang cach tao ViewModel va View rieng, tai su dung cac component hien co.

