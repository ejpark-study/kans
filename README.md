
# kubernetes development experiments with multiple vagrant virtual machine

KANS 1기 종료 과제 일환으로 vagrant 를 이용해 여러 VM 을 생성하고 각종 쿠버네티스 환경을 실험하는 환경 구축을 목표로 한다.

* [KANS 1기 중간 과제](intermediate-assignment.md)

## 개요

![](images/2022-03-12T170200.png)

* DevOps 개발 환경 구축 및 쿠버네티스 개발 환경 구축을 위한 다중 가상 머신 (VM, Virtual Machine) 관리 vagrant 코드.
* 네트워크 리소스 및 시간 절약을 위해 custom vagrant box 를 생성해서 사용.
* 쿠버네티스 환경 구축 실험 이나 DevOps/MLOps 오픈 소스 실험에 적합하도록 개발.
* KANS 1기 스터디 실습에 사용된 vagrantfile 을 참고해서 개발.

## persistent disks

* VM 이 실행되면 docker image 와 disk 가 저장되는 /var/lib/docker 디스크를 생성하고 마운트
* /data 디스크를 생성해서 gitlab, minio 등의 서비스 데이터가 저장될 수 있도록 디스크를 마운트

![img.png](images/2022-03-12T170700.png)

## 시스템 구성

yaml 을 이용한 다중 가상 머신 제어

## devops 용 vagrant box 생성

## kubernetes 실험

## vagrant issue

