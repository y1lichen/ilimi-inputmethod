# Ilimi 一粒米輸入法
要什麼工具就DIY，於是我……利用[InputMethodKit](https://developer.apple.com/documentation/inputmethodkit)開發的仿蝦米

最低系統要求： macOS 13.0+ Ventura.

---

一粒米輸入法的字根檔使用的是[肥米輸入法](https://github.com/shadowjohn/UCL_LIU)的字根檔
⚠️ 因尚未釐清嘸蝦米版權問題，如同肥米輸入法，一粒米輸入法暫不直接發布字根檔。 
一粒米輸入法支援**使用liu.cin字檔**，或是肥米輸入法的liu.json。
可使用各版本之liu.cin，也可發信至  *y1lichen@icloud.com*  或是依照[肥米輸入法](https://github.com/shadowjohn/UCL_LIU)的說明生成liu.json檔案。

## 安裝說明 

建置方式有二：
1. 感謝**威注音作者ShikiSuen**的協作，一粒米已有installer可供下載。
下載並執行完installer後請從「系統偏好設定」 > 「鍵盤」 > 「輸入方式」分頁加入輸入法。
2. 目前repo內提供build.sh，使用方式如下：
```
git clone https://github.com/y1lichen/ilimi-inputmethod.git
cd ilimi-inputmethod
chmod +x ./build.sh
./build.sh
``` 

**下載並啟用一粒米後，一定要點選menubar上一粒米選單的開啟使用者設定目錄，並將字檔放自動開啟之資料夾中，再點選匯入字檔**

## 功能（未完成、仍持續新增）

1. 一般輸入

![一般輸入](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/demo01.gif)

2. 打繁出簡
輸入,,CT切換打繁出簡模

![打繁出簡](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/demo02.gif)
 
3. 加v、r、s等輔助選字
4. 注音輸入

![注音輸入](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/zhuyin_demo.gif)

若要啟用注音輸入法，必須要將[pinyin.json](https://github.com/y1lichen/ilimi-inputmethod/blob/main/others/pinyin.json)
檔案放在/Library/Containers/ilimi/Data，或是自選單欄選開啟使用者設定目錄並將pinyin.json放入其中。

輸入';即可使用注音輸入

5. 英數模式

使用CapsLock即可切換英數模式

![英數模式](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/ascii_demo.gif)
 
6. 反查注音、輸入碼

輸入 **,,q** 可快速開啟反查注音/查碼畫面

![反查](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/demo03.gif)

7. 同音輸入

![同音輸入](https://github.com/y1lichen/ilimi-inputmethod/blob/main/media/demo04.gif)

8. 全形模式

輸入shift+空白鍵可以進入全形模式

## 可自定義項目

- 選字窗字體大小
- 選字窗樣式（直式、橫式）
- 是否在沒有候選字時限制輸入（在沒候選字時按下enter可以直接輸入英文字母）
- 是否在使用注音輸入後提示拆碼
- 靜音模式（在輸入錯誤時發出beep）

## Reference

本專案的IMK機制參考 2.x 版本的[vChewing威注音](https://vchewing.github.io/README.html)，該專案的源碼對IMK許多函式有清楚註解

[https://mzp.hatenablog.com/entry/2017/09/17/220320](https://mzp.hatenablog.com/entry/2017/09/17/220320)
[https://arika.org/2022/04/02/macos-inputmethodkit/](https://arika.org/2022/04/02/macos-inputmethodkit/)

---

打繁出簡模式的「繁體字轉簡體字」程式碼是由[GBig](https://github.com/RockfordWei/GBig)修改而來，利用dictionary加速查找速度。
