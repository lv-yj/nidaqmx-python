<%
    from codegen.utilities.text_wrappers import wrap
    from codegen.utilities.function_helpers import get_functions,  get_enums_used
    functions = get_functions(data, "AOChannelCollection")
    enums_used = get_enums_used(functions)
%>\
# Do not edit this file; it was automatically generated.

import ctypes

from nidaqmx._lib import lib_importer, ctypes_byte_str
from nidaqmx.errors import check_for_error
from nidaqmx._task_modules.channels.ao_channel import AOChannel
from nidaqmx._task_modules.channel_collection import ChannelCollection
from nidaqmx.utils import unflatten_channel_string
%if enums_used:
from nidaqmx.constants import (
    ${', '.join([c for c in enums_used]) | wrap(4, 4)})
%endif


class AOChannelCollection(ChannelCollection):
    """
    Contains the collection of analog output channels for a DAQmx Task.
    """
    def __init__(self, task_handle):
        super().__init__(task_handle)

    def _create_chan(self, physical_channel, name_to_assign_to_channel=''):
        """
        Creates and returns an AOChannel object.

        Args:
            physical_channel (str): Specifies the names of the physical
                channels to use to create virtual channels.
            name_to_assign_to_channel (Optional[str]): Specifies a name to
                assign to the virtual channel this method creates.
        Returns:
            nidaqmx._task_modules.channels.ao_channel.AOChannel: 
            
            Specifies the newly created AOChannel object.
        """
        if name_to_assign_to_channel:
            num_channels = len(unflatten_channel_string(physical_channel))

            if num_channels > 1:
                name = '{}0:{}'.format(
                    name_to_assign_to_channel, num_channels-1)
            else:
                name = name_to_assign_to_channel
        else:
            name = physical_channel

        return AOChannel(self._handle, name)

<%namespace name="function_template" file="/function_template.py.mako"/>\
%for function_object in functions:
${function_template.script_function(function_object)}
%endfor