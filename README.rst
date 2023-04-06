===========  =================================================================================================================================
Info         Contains a Python API for interacting with NI-DAQmx. See `GitHub <https://github.com/ni/nidaqmx-python/>`_ for the latest source.
Author       National Instruments
===========  =================================================================================================================================

About
=====

**nidaqmx** 패키지는 NI-DAQmx 드라이버와 상호 작용하기 위한 API(Application Programming Interface)가 포함되어 있습니다. 
이 패키지는 Python으로 구현되었습니다.
이 패키지는 `ctypes <https://docs.python.org/2/library/ctypes.html>`_ Python library를 사용하여 
NI-DAQmx C API 주변의 복잡하고 고도로 객체 지향적인 래퍼로 구현됩니다 

**nidaqmx**는 C API와 함께 제공되는 모든 버전의 NI-DAQmx 드라이버를 지원합니다. 
C API는 이를 지원하는 모든 버전의 드라이버에 포함되어 있습니다. 
**nidaqmx** 패키지 는 C 헤더 파일을 설치할 필요가 없습니다.

**nidaqmx** 패키지 의 일부 기능은 이전 버전의 NI-DAQmx 드라이버에서 사용하지 못할 수 있습니다. 
NI-DAQmx 버전을 업그레이드하려면 `ni.com/downloads <http://www.ni.com/downloads/>`_를 방문하십시오 .

**nidaqmx**는 NI-DAQmx 드라이버가 지원되는 Windows 및 Linux 운영 체제를 지원합니다. 
주어진 운영 체제에서 하드웨어를 지원하는 드라이버 버전에 대해서는 `NI 하드웨어 및 운영 체제 호환성 <https://www.ni.com/r/hw-support>`_을 참조하십시오.

**nidaqmx**는 CPython 3.7+ 및 PyPy3를 지원합니다.

Installation
============

**nidaqmx**를 실행하려면 NI-DAQmx를 설치해야 합니다. 
최신 버전의 NI-DAQmx를 다운로드하려면 `ni.com/downloads <http://www.ni.com/downloads/>`_를 방문하십시오. 
**권장되는 추가 항목**은 nidaqmx가 작동하는 데 필요 하지 않으며 설치 크기를 최소화하기 위해 제거할 수 있습니다. 
운영 체제가 NI 빌드 바이너리를 신뢰할 수 있도록 **NI 인증서** 패키지를 계속 설치하여 소프트웨어 및 하드웨어 설치 경험을 개선하는 것이 좋습니다 .

**nidaqmx**는 `pip <http://pypi.python.org/pypi/pip>`_로 설치할 수 있습니다::

  $ python -m pip install nidaqmx

Similar Packages
================

There are similar packages available that also provide NI-DAQmx functionality in
Python:

- `daqmx <https://pypi.org/project/daqmx/>`_
  (`slightlynybbled/daqmx on GitHub <https://github.com/slightlynybbled/daqmx>`_)
  provides an abstraction of NI-DAQmx in the ``ni`` module.

- PyLibNIDAQmx (`pearu/pylibnidaqmx on GitHub <https://github.com/pearu/pylibnidaqmx>`_)
  provides an abstraction of NI-DAQmx in the ``nidaqmx`` module, which collides
  with this package's module name.

.. _usage-section:

Usage
=====
The following is a basic example of using an **nidaqmx.task.Task** object. 
This example illustrates how the single, dynamic **nidaqmx.task.Task.read** 
method returns the appropriate data type.

.. code-block:: python

  >>> import nidaqmx
  >>> with nidaqmx.Task() as task:
  ...     task.ai_channels.add_ai_voltage_chan("Dev1/ai0")
  ...     task.read()
  ...
  -0.07476920729381246
  >>> with nidaqmx.Task() as task:
  ...     task.ai_channels.add_ai_voltage_chan("Dev1/ai0")
  ...     task.read(number_of_samples_per_channel=2)
  ...
  [0.26001373311970705, 0.37796597238117036]
  >>> from nidaqmx.constants import LineGrouping
  >>> with nidaqmx.Task() as task:
  ...     task.di_channels.add_di_chan(
  ...         "cDAQ2Mod4/port0/line0:1", line_grouping=LineGrouping.CHAN_PER_LINE)
  ...     task.read(number_of_samples_per_channel=2)
  ...
  [[False, True], [True, True]]

A single, dynamic **nidaqmx.task.Task.write** method also exists.

.. code-block:: python

  >>> import nidaqmx
  >>> from nidaqmx.types import CtrTime
  >>> with nidaqmx.Task() as task:
  ...     task.co_channels.add_co_pulse_chan_time("Dev1/ctr0")
  ...     sample = CtrTime(high_time=0.001, low_time=0.001)
  ...     task.write(sample)
  ...
  1
  >>> with nidaqmx.Task() as task:
  ...     task.ao_channels.add_ao_voltage_chan("Dev1/ao0")
  ...     task.write([1.1, 2.2, 3.3, 4.4, 5.5], auto_start=True)
  ...
  5

Consider using the **nidaqmx.stream_readers** and **nidaqmx.stream_writers**
classes to increase the performance of your application, which accept pre-allocated
NumPy arrays.

Following is an example of using an **nidaqmx.system.System** object.

.. code-block:: python

  >>> import nidaqmx.system
  >>> system = nidaqmx.system.System.local()
  >>> system.driver_version
  DriverVersion(major_version=16L, minor_version=0L, update_version=0L)
  >>> for device in system.devices:
  ...     print(device)
  ...
  Device(name=Dev1)
  Device(name=Dev2)
  Device(name=cDAQ1)
  >>> import collections
  >>> isinstance(system.devices, collections.Sequence)
  True
  >>> device = system.devices['Dev1']
  >>> device == nidaqmx.system.Device('Dev1')
  True
  >>> isinstance(device.ai_physical_chans, collections.Sequence)
  True
  >>> phys_chan = device.ai_physical_chans['ai0']
  >>> phys_chan
  PhysicalChannel(name=Dev1/ai0)
  >>> phys_chan == nidaqmx.system.PhysicalChannel('Dev1/ai0')
  True
  >>> phys_chan.ai_term_cfgs
  [<TerminalConfiguration.RSE: 10083>, <TerminalConfiguration.NRSE: 10078>, <TerminalConfiguration.DIFFERENTIAL: 10106>]
  >>> from enum import Enum
  >>> isinstance(phys_chan.ai_term_cfgs[0], Enum)
  True

Bugs / Feature Requests
=======================

To report a bug or submit a feature request, please use the 
`GitHub issues page <https://github.com/ni/nidaqmx-python/issues>`_.

Information to Include When Asking for Help
-------------------------------------------

Please include **all** of the following information when opening an issue:

- Detailed steps on how to reproduce the problem and full traceback, if 
  applicable.
- The python version used::

  $ python -c "import sys; print(sys.version)"

- The versions of the **nidaqmx** and numpy packages used::

  $ python -m pip list

- The version of the NI-DAQmx driver used. Follow 
  `this KB article <http://digital.ni.com/express.nsf/bycode/ex8amn>`_ 
  to determine the version of NI-DAQmx you have installed.
- The operating system and version, for example Windows 7, CentOS 7.2, ...

Documentation
=============

Documentation is available `here <http://nidaqmx-python.readthedocs.io>`_.

Additional Documentation
========================

Refer to the `NI-DAQmx Help <http://digital.ni.com/express.nsf/bycode/exagg4>`_ 
for API-agnostic information about NI-DAQmx or measurement concepts.

NI-DAQmx Help installs only with the full version of NI-DAQmx.

License
=======

**nidaqmx** is licensed under an MIT-style license (see
`LICENSE <https://github.com/ni/nidaqmx-python/blob/master/LICENSE>`_).
Other incorporated projects may be licensed under different licenses. All
licenses allow for non-commercial and commercial use.
