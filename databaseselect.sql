USE SiteYonetimPlatformu;
GO

-- ============================================================
-- SORGU 1
-- Tahakkuk tarihi içinde bulunulan yıl olan aidat kayıtları
-- arasından, her blok için en yüksek toplam borç tutarına
-- sahip olan kayıt(lar):
-- BLOK ADI | SAKİN_ADI_SOYADI | TAHAKKUK_TARİHİ | TOPLAM_BORÇ_TUTARI
-- ============================================================
SELECT
    B.ad                       AS BLOK_ADI,
    S.ad + ' ' + S.soyad       AS SAKIN_ADI_SOYADI,
    F.tahakkuk_tarihi          AS TAHAKKUK_TARIHI,
    F.toplam_borc              AS TOPLAM_BORC_TUTARI
FROM FATURA F
JOIN SAKIN  S  ON F.tc_kimlik = S.tc_kimlik
JOIN IKAMET I  ON S.tc_kimlik = I.tc_kimlik AND I.aktif = 1
JOIN DAIRE  D  ON I.daire_no  = D.daire_no
JOIN BLOK   B  ON D.blok_id   = B.blok_id
WHERE YEAR(F.tahakkuk_tarihi) = YEAR(GETDATE())
  AND F.toplam_borc = (
          SELECT MAX(F2.toplam_borc)
          FROM   FATURA  F2
          JOIN   SAKIN   S2 ON F2.tc_kimlik = S2.tc_kimlik
          JOIN   IKAMET  I2 ON S2.tc_kimlik = I2.tc_kimlik AND I2.aktif = 1
          JOIN   DAIRE   D2 ON I2.daire_no  = D2.daire_no
          WHERE  D2.blok_id = D.blok_id
            AND  YEAR(F2.tahakkuk_tarihi) = YEAR(GETDATE())
      )
ORDER BY B.ad;


-- ============================================================
-- SORGU 2
-- Aşağıdaki koşulların tamamını sağlayan aktif sakinler:
--   • 'TENIS-01' kodlu tesiste en az 2 kez rezervasyon yapmış
--   • 'HAVUZ-01' kodlu tesiste en az 3 kez rezervasyon yapmış
--   • Tüm aktif tesisleri en az bir kez kullanmış
-- AD | SOYAD | AKTİF_DAİRE_KODU | SON_REZERVASYON_TARİHİ
-- ============================================================
SELECT
    S.ad                  AS AD,
    S.soyad               AS SOYAD,
    D.kapi_no             AS AKTIF_DAIRE_KODU,
    MAX(TK.tarih)         AS SON_REZERVASYON_TARIHI
FROM SAKIN S
JOIN IKAMET         I   ON S.tc_kimlik     = I.tc_kimlik    AND I.aktif = 1
JOIN DAIRE          D   ON I.daire_no      = D.daire_no
JOIN KULLANICI      KU  ON KU.ad           = S.ad
                       AND KU.soyad        = S.soyad
                       AND KU.kullanici_tipi = 'Sakin'
JOIN TESIS_KULLANIM TK  ON KU.kullanici_id = TK.kullanici_id
GROUP BY
    S.tc_kimlik,
    S.ad,
    S.soyad,
    D.kapi_no
HAVING
    -- Koşul 1: TENIS-01 kodlu tesiste en az 2 kez rezervasyon yapmış olmalı
    SUM(CASE WHEN TK.tesis_id = (SELECT tesis_id FROM TESIS WHERE tesis_kodu = 'TENIS-01')
             THEN 1 ELSE 0 END) >= 2

    -- Koşul 2: HAVUZ-01 kodlu tesiste en az 3 kez rezervasyon yapmış olmalı
    AND SUM(CASE WHEN TK.tesis_id = (SELECT tesis_id FROM TESIS WHERE tesis_kodu = 'HAVUZ-01')
                 THEN 1 ELSE 0 END) >= 3

    -- Koşul 3: Tüm aktif tesisleri en az bir kez kullanmış olmalı (gelmedi_mi = 0 olanlar sayılır)
    AND COUNT(DISTINCT CASE WHEN TK.gelmedi_mi = 0 THEN TK.tesis_id END) = (SELECT COUNT(*) FROM TESIS WHERE aktif = 1)
ORDER BY SON_REZERVASYON_TARIHI DESC;