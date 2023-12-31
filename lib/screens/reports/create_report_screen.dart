import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/traffic_violation.dart';
import '../../services/report_service.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final List<XFile> _mediaFiles = [];
  final TrafficViolation _violation = TrafficViolation(
    date: DateTime.now(),
    time: TimeOfDay.now(),
    violation: '紅線停車',
    status: 'Pending',
  );

  // 违规类型选项
  final List<String> _violations = [
    '紅線停車',
    '黃線臨車',
    '行駛人行道',
    '未停讓行人',
    '切換車道未打方向燈',
    '人行道停車',
    '騎樓停車',
    '闖紅燈',
    '逼車',
    '未禮讓直行車',
    '未依標線行駛',
    '其他',
  ];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_violation.date!);
    _timeController.text = _violation.time!.format(context);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  onSaved: (value) => _violation.licensePlate = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a license plate';
                    }
                    return null;
                  },
                ),
                // Date Picker
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  controller: _dateController,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _violation.date!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _violation.date = pickedDate;
                        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                // Time Picker
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Time'),
                  readOnly: true,
                  controller: _timeController,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _violation.time!,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _violation.time = pickedTime;
                        _timeController.text = pickedTime.format(context);
                      });
                    }
                  },
                ),
                // Violation Dropdown
                DropdownButtonFormField<String>(
                  value: _violation.violation,
                  decoration: const InputDecoration(labelText: 'Violation'),
                  items: _violations.map((String violation) {
                    return DropdownMenuItem<String>(
                      value: violation,
                      child: Text(violation),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _violation.violation = newValue;
                    });
                  },
                  onSaved: (String? newValue) {
                    _violation.violation = newValue;
                  },
                ), // 添加了这个闭合括号来结束 DropdownButtonFormField
                // Status Dropdown
                DropdownButtonFormField<String>(
                    value: _violation.status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: TrafficViolation.statusOptions.map((status) {
                    return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                    );
                    }).toList(),
                    onChanged: (value) {
                    setState(() {
                        _violation.status = value;
                    });
                    },
                ),
                // Location Field
                TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onSaved: (value) => _violation.location = value,
                ),
                // Officer Field
                TextFormField(
                    decoration: const InputDecoration(labelText: 'Officer'),
                    onSaved: (value) => _violation.officer = value,
                ),
                // Media Upload
                ElevatedButton(
                    onPressed: () => _pickMedia(),
                    child: const Text('Add Media'),
                ),
                const SizedBox(height: 10),
                _buildMediaPreview(),
                // Submit Button
                ElevatedButton(
                    onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _submitReport();
                    }
                  },
                  child: const Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickMedia() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _mediaFiles.addAll(pickedFiles);
    });
  }

  Widget _buildMediaPreview() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _mediaFiles.map((file) {
        return Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Image.file(File(file.path), width: 100, height: 100),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () => _removeMedia(file),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _removeMedia(XFile file) {
    setState(() {
      _mediaFiles.remove(file);
    });
  }

  void _submitReport() async {
    // 获取 context 依赖的信息
    final reportService = Provider.of<ReportService>(context, listen: false);

    bool success = await reportService.createReport(_violation, _mediaFiles);
    
    if (!mounted) return; // 检查组件是否仍然挂载

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit report')));
    }
  }
}
