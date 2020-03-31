package unisig

import (
	"errors"
	"os"
)

const magic = "\xDC\xDC\x0D\x0A\x1A\x0A\x00"

func Read(f os.File) (string, bool, error) {
	head := make([]byte, len(magic)+1)
	n, err := f.Read(head)
	if err != nil {
		return "", false, err
	}
	if n != len(head) {
		return "", false, errors.New("short read")
	}
	lenbyte := head[len(magic)]
	isUUID := (lenbyte == 0)
	length := int(lenbyte)
	if isUUID {
		length = 16
	}
	sig := make([]byte, length)
	n, err = f.Read(sig)
	if err != nil {
		return "", false, err
	}
	if n != length {
		return "", false, errors.New("short read")
	}
	return string(sig), isUUID, nil
}

func WriteURI(f os.File, uri string) error {
	if len(uri) > 255 {
		return errors.New("URI too long")
	}
	whole := append([]byte(magic), byte(len(uri)))
	whole = append(whole, uri...)
	_, err := f.Write(whole)
	return err
}

func WriteUUID(f os.File, uuid string) error {
	if len(uuid) != 16 {
		return errors.New("UUID not 16 bytes")
	}
	whole := append([]byte(magic), 0)
	whole = append(whole, []byte(uuid)...)
	_, err := f.Write(whole)
	return err
}
