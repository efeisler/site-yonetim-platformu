CREATE DATABASE SiteYonetimPlatformu;
GO

USE SiteYonetimPlatformu;
GO

CREATE TABLE IL_ILCE (
    ilce_id     INT          NOT NULL IDENTITY(1,1),
    il_adi      VARCHAR(50)  NOT NULL,
    ilce_adi    VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_IL_ILCE PRIMARY KEY (ilce_id)
);

CREATE TABLE BLOK (
    blok_id     INT          NOT NULL IDENTITY(1,1),
    ad          VARCHAR(20)  NOT NULL,
    insa_yili   INT          NULL,
    aktif       BIT          NOT NULL DEFAULT 1,
    aciklama    VARCHAR(500) NULL,
    CONSTRAINT PK_BLOK PRIMARY KEY (blok_id)
);

CREATE TABLE DAIRE_TIPI (
    tip_id       INT           NOT NULL IDENTITY(1,1),
    tip_adi      VARCHAR(20)   NOT NULL,
    aidat_tutari DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DAIRE_TIPI PRIMARY KEY (tip_id)
);

CREATE TABLE DAIRE (
    daire_no  INT           NOT NULL IDENTITY(1,1),
    blok_id   INT           NOT NULL,
    tip_id    INT           NOT NULL,
    kapi_no   VARCHAR(10)   NOT NULL,
    kat       INT           NOT NULL,
    brut_m2   DECIMAL(8,2)  NOT NULL,
    net_m2    DECIMAL(8,2)  NOT NULL,
    aciklama  VARCHAR(500)  NULL,
    CONSTRAINT PK_DAIRE      PRIMARY KEY (daire_no),
    CONSTRAINT FK_DAIRE_BLOK FOREIGN KEY (blok_id) REFERENCES BLOK(blok_id),
    CONSTRAINT FK_DAIRE_TIPI FOREIGN KEY (tip_id)  REFERENCES DAIRE_TIPI(tip_id)
);

CREATE TABLE SAKIN (
    tc_kimlik      CHAR(11)     NOT NULL,
    ad             VARCHAR(50)  NOT NULL,
    soyad          VARCHAR(50)  NOT NULL,
    cinsiyet       CHAR(1)      NULL,
    dogum_tarihi   DATE         NULL,
    yas            AS (DATEDIFF(YEAR, dogum_tarihi, GETDATE())),
    telefon        VARCHAR(15)  NULL,
    e_posta        VARCHAR(100) NULL,
    sifre          VARCHAR(256) NOT NULL,
    ilce_id        INT          NULL,
    adres_aciklama VARCHAR(500) NULL,
    CONSTRAINT PK_SAKIN          PRIMARY KEY (tc_kimlik),
    CONSTRAINT FK_SAKIN_ILCE     FOREIGN KEY (ilce_id) REFERENCES IL_ILCE(ilce_id),
    CONSTRAINT CK_SAKIN_CINSIYET CHECK (cinsiyet IN ('E', 'K'))
);

CREATE TABLE IKAMET (
    tc_kimlik      CHAR(11) NOT NULL,
    daire_no       INT      NOT NULL,
    tasinma_tarihi DATE     NOT NULL,
    ayrilma_tarihi DATE     NULL,
    aktif          BIT      NOT NULL DEFAULT 0,
    CONSTRAINT PK_IKAMET       PRIMARY KEY (tc_kimlik, daire_no, tasinma_tarihi),
    CONSTRAINT FK_IKAMET_SAKIN FOREIGN KEY (tc_kimlik) REFERENCES SAKIN(tc_kimlik),
    CONSTRAINT FK_IKAMET_DAIRE FOREIGN KEY (daire_no)  REFERENCES DAIRE(daire_no)
);

CREATE TABLE ODEME_TIPI (
    odeme_tip_id INT         NOT NULL IDENTITY(1,1),
    tip_adi      VARCHAR(30) NOT NULL,
    CONSTRAINT PK_ODEME_TIPI PRIMARY KEY (odeme_tip_id)
);

CREATE TABLE FATURA (
    fatura_id         INT           NOT NULL IDENTITY(1,1),
    daire_no          INT           NOT NULL,
    tc_kimlik         CHAR(11)      NOT NULL,
    aidat_tutari      DECIMAL(10,2) NOT NULL,
    toplam_odenen     DECIMAL(10,2) NOT NULL DEFAULT 0,
    toplam_borc       DECIMAL(10,2) NOT NULL DEFAULT 0,
    kalan_tutar       DECIMAL(10,2) NOT NULL DEFAULT 0,
    tahakkuk_tarihi   DATE          NOT NULL,
    genel_borc_durumu VARCHAR(20)   NOT NULL DEFAULT 'Odenmedi',
    CONSTRAINT PK_FATURA       PRIMARY KEY (fatura_id),
    CONSTRAINT FK_FATURA_DAIRE FOREIGN KEY (daire_no)  REFERENCES DAIRE(daire_no),
    CONSTRAINT FK_FATURA_SAKIN FOREIGN KEY (tc_kimlik) REFERENCES SAKIN(tc_kimlik)
);

CREATE TABLE GIDER_TIPI (
    gider_tip_id INT         NOT NULL IDENTITY(1,1),
    gider_adi    VARCHAR(50) NOT NULL,
    CONSTRAINT PK_GIDER_TIPI PRIMARY KEY (gider_tip_id)
);

CREATE TABLE GIDER_KALEMI (
    kalem_id     INT           NOT NULL IDENTITY(1,1),
    fatura_id    INT           NOT NULL,
    gider_tip_id INT           NOT NULL,
    gider_tutari DECIMAL(10,2) NOT NULL,
    donem        VARCHAR(20)   NOT NULL,
    CONSTRAINT PK_GIDER_KALEMI        PRIMARY KEY (kalem_id),
    CONSTRAINT FK_GIDER_KALEMI_FATURA FOREIGN KEY (fatura_id)    REFERENCES FATURA(fatura_id),
    CONSTRAINT FK_GIDER_KALEMI_TIP    FOREIGN KEY (gider_tip_id) REFERENCES GIDER_TIPI(gider_tip_id)
);

CREATE TABLE TAHSILAT (
    tahsilat_id  INT           NOT NULL IDENTITY(1,1),
    fatura_id    INT           NOT NULL,
    odeme_tip_id INT           NOT NULL,
    odeme_tarihi DATE          NOT NULL,
    odenen_tutar DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_TAHSILAT            PRIMARY KEY (tahsilat_id),
    CONSTRAINT FK_TAHSILAT_FATURA     FOREIGN KEY (fatura_id)    REFERENCES FATURA(fatura_id),
    CONSTRAINT FK_TAHSILAT_ODEME_TIPI FOREIGN KEY (odeme_tip_id) REFERENCES ODEME_TIPI(odeme_tip_id)
);

CREATE TABLE TESIS (
    tesis_id      INT          NOT NULL IDENTITY(1,1),
    tesis_adi     VARCHAR(100) NOT NULL,
    tesis_kodu    VARCHAR(20)  NOT NULL UNIQUE,
    konum         VARCHAR(20)  NULL,
    kullanim_turu VARCHAR(50)  NULL,
    blok_id       INT          NULL,
    dahili_tel    VARCHAR(15)  NULL,
    kapasite      INT          NULL,
    aktif         BIT          NOT NULL DEFAULT 1,
    CONSTRAINT PK_TESIS      PRIMARY KEY (tesis_id),
    CONSTRAINT FK_TESIS_BLOK FOREIGN KEY (blok_id) REFERENCES BLOK(blok_id)
);

CREATE TABLE KULLANICI (
    kullanici_id   INT         NOT NULL IDENTITY(1,1),
    ad             VARCHAR(50) NOT NULL,
    soyad          VARCHAR(50) NOT NULL,
    telefon        VARCHAR(15) NULL,
    kullanici_tipi VARCHAR(10) NOT NULL,
    CONSTRAINT PK_KULLANICI PRIMARY KEY (kullanici_id)
);

CREATE TABLE TESIS_KULLANIM (
    kullanim_id    INT  NOT NULL IDENTITY(1,1),
    tesis_id       INT  NOT NULL,
    kullanici_id   INT  NOT NULL,
    tarih          DATE NOT NULL,
    baslangic_saat TIME NOT NULL,
    bitis_saat     TIME NOT NULL,
    gelmedi_mi     BIT  NOT NULL DEFAULT 0,
    CONSTRAINT PK_TESIS_KULLANIM       PRIMARY KEY (kullanim_id),
    CONSTRAINT FK_TESIS_KULLANIM_TESIS FOREIGN KEY (tesis_id)     REFERENCES TESIS(tesis_id),
    CONSTRAINT FK_TESIS_KULLANIM_KULL  FOREIGN KEY (kullanici_id) REFERENCES KULLANICI(kullanici_id)
);

CREATE TABLE MALZEME (
    malzeme_id    INT          NOT NULL IDENTITY(1,1),
    malzeme_adi   VARCHAR(100) NOT NULL,
    kategori      VARCHAR(50)  NULL,
    mevcut_miktar INT          NOT NULL DEFAULT 0,
    CONSTRAINT PK_MALZEME PRIMARY KEY (malzeme_id)
);

CREATE TABLE CALISAN (
    calisan_id     INT          NOT NULL IDENTITY(1,1),
    tc_kimlik      CHAR(11)     NOT NULL UNIQUE,
    ad             VARCHAR(50)  NOT NULL,
    soyad          VARCHAR(50)  NOT NULL,
    telefon        VARCHAR(15)  NULL,
    e_posta        VARCHAR(100) NULL,
    unvan          VARCHAR(50)  NULL,
    kurum_taseron  VARCHAR(100) NULL,
    iban           VARCHAR(34)  NULL,
    ilce_id        INT          NULL,
    adres_aciklama VARCHAR(500) NULL,
    CONSTRAINT PK_CALISAN      PRIMARY KEY (calisan_id),
    CONSTRAINT FK_CALISAN_ILCE FOREIGN KEY (ilce_id) REFERENCES IL_ILCE(ilce_id)
);

CREATE TABLE IS_EMRI (
    is_emri_no       INT           NOT NULL IDENTITY(1,1),
    oncelik_grubu    CHAR(1)       NOT NULL,
    aciklama         VARCHAR(1000) NULL,
    olusturma_tarihi DATE          NOT NULL DEFAULT GETDATE(),
    durum            VARCHAR(20)   NOT NULL DEFAULT 'Acik',
    CONSTRAINT PK_IS_EMRI PRIMARY KEY (is_emri_no)
);

CREATE TABLE COZUM (
    cozum_id   INT           NOT NULL IDENTITY(1,1),
    is_emri_no INT           NOT NULL,
    calisan_id INT           NOT NULL,
    aciklama   VARCHAR(1000) NULL,
    is_tarihi  DATE          NOT NULL,
    CONSTRAINT PK_COZUM         PRIMARY KEY (cozum_id),
    CONSTRAINT FK_COZUM_IS_EMRI FOREIGN KEY (is_emri_no) REFERENCES IS_EMRI(is_emri_no),
    CONSTRAINT FK_COZUM_CALISAN FOREIGN KEY (calisan_id) REFERENCES CALISAN(calisan_id)
);

CREATE TABLE MALZEME_KULLANIMI (
    cozum_id   INT NOT NULL,
    malzeme_id INT NOT NULL,
    miktar     INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_MALZEME_KULLANIMI   PRIMARY KEY (cozum_id, malzeme_id),
    CONSTRAINT FK_MALZEME_KUL_COZUM   FOREIGN KEY (cozum_id)   REFERENCES COZUM(cozum_id),
    CONSTRAINT FK_MALZEME_KUL_MALZEME FOREIGN KEY (malzeme_id) REFERENCES MALZEME(malzeme_id)
);

CREATE TABLE DEGERLENDIRME (
    degerlendirme_id INT           NOT NULL IDENTITY(1,1),
    kullanici_id     INT           NOT NULL,
    tesis_id         INT           NULL,
    is_emri_no       INT           NULL,
    puan             TINYINT       NOT NULL,
    yorum_metni      VARCHAR(1000) NULL,
    tarih            DATE          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_DEGERLENDIRME       PRIMARY KEY (degerlendirme_id),
    CONSTRAINT FK_DEGERL_KULLANICI    FOREIGN KEY (kullanici_id) REFERENCES KULLANICI(kullanici_id),
    CONSTRAINT FK_DEGERL_TESIS        FOREIGN KEY (tesis_id)     REFERENCES TESIS(tesis_id),
    CONSTRAINT FK_DEGERL_IS_EMRI      FOREIGN KEY (is_emri_no)   REFERENCES IS_EMRI(is_emri_no),
    CONSTRAINT CK_DEGERLENDIRME_PUAN  CHECK (puan BETWEEN 1 AND 5),
    CONSTRAINT CK_DEGERLENDIRME_HEDEF CHECK (
        (tesis_id IS NOT NULL AND is_emri_no IS NULL) OR
        (tesis_id IS NULL     AND is_emri_no IS NOT NULL)
    )
);