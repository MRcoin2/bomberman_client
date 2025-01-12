import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/game_data_provider.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _onMessageCalled = false;
  TextEditingController _widthController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _blockDensityController = TextEditingController();
  TextEditingController _gameTimeController = TextEditingController();
  TextEditingController _livesController = TextEditingController();
  TextEditingController _startPowerController = TextEditingController();
  TextEditingController _startBombsController = TextEditingController();
  TextEditingController _startSpeedController = TextEditingController();

  void _sendSettings(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Provider.of<GameDataProvider>(context, listen: false).sendMessage(
        '{"Type":"CLIENT_LOBBY_UPDATE_SETTINGS",'
            '"Payload":'
            '{"Width":${int.parse(_widthController.text).round()},'
            '"Height":${int.parse(_heightController.text).round()},'
            '"BlockDensity":${double.parse(_blockDensityController.text)},'
            '"GameTime":${int.parse(_gameTimeController.text).round()},'
            '"Lives":${int.parse(_livesController.text).round()},'
            '"StartPower":${int.parse(_startPowerController.text).round()},'
            '"StartBombs":${int.parse(_startBombsController.text).round()},'
            '"StartSpeed":${double.parse(_startSpeedController.text)}}}');
  }

  void _updateSettings(Map<String, dynamic> settings) {
    void updateController(TextEditingController controller, dynamic value) {
      final cursorPos = controller.selection;
      controller.text = (value ?? 0).toString();
      controller.selection = TextSelection.collapsed(
        offset: cursorPos.start.clamp(0, controller.text.length),
      );
    }

    updateController(_widthController, settings['Width']);
    updateController(_heightController, settings['Height']);
    updateController(_blockDensityController, settings['BlockDensity']);
    updateController(_gameTimeController, settings['GameTime']);
    updateController(_livesController, settings['Lives']);
    updateController(_startPowerController, settings['StartPower']);
    updateController(_startBombsController, settings['StartBombs']);
    updateController(_startSpeedController, settings['StartSpeed']);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_onMessageCalled) {
      _onMessageCalled = true;
      Provider.of<GameDataProvider>(context).onMessage((message) {
        //decode the json message
        var data = jsonDecode(message);
        //print(data);
        if (data['Type'] == 'SERVER_LOBBY_UPDATE_SETTINGS') {
          _updateSettings(data['Payload']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          const ListTile(
            title: Text('Settings', style: TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: () => _sendSettings(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _widthController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }else if(int.parse(value) < 10 || int.parse(value) > 50){
                                    return 'Please enter a value between 10 and 50';
                                  }else if (int.parse(value) % 2 != 1){
                                    return 'Please enter an odd number';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Width',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _heightController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }else if(int.parse(value) < 10 || int.parse(value) > 50){
                                    return 'Please enter a value between 10 and 50';
                                  }else if (int.parse(value) % 2 != 1){
                                    return 'Please enter an odd number';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Height',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField( // Block Density is from 0.0 to 1.0
                                controller: _blockDensityController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  try{
                                    double.parse(value!);
                                  }catch(e){
                                    return 'Please enter a valid number e.g. 0.5';
                                  }
                                  if(double.parse(value) < 0 || double.parse(value) > 1){
                                    return 'Please enter a value between 0 and 1';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],

                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Block Density',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _gameTimeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Round time',
                                  suffixText: 's',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _livesController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Lives',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _startPowerController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Start Power',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _startBombsController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Start Bombs',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _startSpeedController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Start speed',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
