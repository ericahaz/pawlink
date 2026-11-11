part of pawlink_admin;

class QrFoundPetPage extends StatefulWidget {
  final PetRecord pet;

  const QrFoundPetPage({
    super.key,
    required this.pet,
  });

  @override
  State<QrFoundPetPage> createState() =>
      _QrFoundPetPageState();
}

class _QrFoundPetPageState
    extends State<QrFoundPetPage> {
  final finderController =
      TextEditingController();
  final contactController =
      TextEditingController();
  final locationController =
      TextEditingController();
  final notesController =
      TextEditingController();

  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        title: const Text(
          'Report Found Pet',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),
            child: AppCard(
              child: Padding(
                padding:
                    const EdgeInsets.all(28),
                child: submitted
                    ? Column(
                        children: [
                          const Icon(
                            Icons
                                .check_circle_outline,
                            color: successText,
                            size: 65,
                          ),
                          const SizedBox(
                              height: 14),
                          const Text(
                            'Found Pet Report Submitted',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          const SizedBox(
                              height: 8),
                          Text(
                            'The QR report for ${widget.pet.name} '
                            'has been added to PawLink.',
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color: textMuted,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'You found a registered PawLink pet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          const SizedBox(
                              height: 5),
                          Text(
                            '${widget.pet.name} • ${widget.pet.animalType} • ${widget.pet.breed}',
                            style:
                                const TextStyle(
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(
                              height: 23),
                          const FormLabel(
                            'Your Name',
                          ),
                          TextField(
                            controller:
                                finderController,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Finder name',
                            ),
                          ),
                          const SizedBox(
                              height: 14),
                          const FormLabel(
                            'Contact Number',
                          ),
                          TextField(
                            controller:
                                contactController,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Contact number',
                            ),
                          ),
                          const SizedBox(
                              height: 14),
                          const FormLabel(
                            'Found Location',
                          ),
                          TextField(
                            controller:
                                locationController,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Location or landmark',
                              prefixIcon: Icon(
                                Icons
                                    .location_on_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 14),
                          const FormLabel(
                            'Condition / Notes',
                          ),
                          TextField(
                            controller:
                                notesController,
                            maxLines: 4,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Describe the pet\'s condition.',
                            ),
                          ),
                          const SizedBox(
                              height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'The photo button is ready for Firebase Storage integration.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons
                                  .add_photo_alternate_outlined,
                            ),
                            label: const Text(
                              'Add Found Pet Photo',
                            ),
                          ),
                          const SizedBox(
                              height: 23),
                          SizedBox(
                            width:
                                double.infinity,
                            height: 48,
                            child:
                                FilledButton.icon(
                              style:
                                  FilledButton
                                      .styleFrom(
                                backgroundColor:
                                    forestGreen,
                              ),
                              onPressed: () {
                                if (locationController
                                    .text
                                    .trim()
                                    .isEmpty) {
                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter where the pet was found.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final report =
                                    AnimalReport(
                                  id:
                                      'FND-${DateTime.now().millisecondsSinceEpoch}',
                                  type: 'Found',
                                  animalType:
                                      widget.pet
                                          .animalType,
                                  petName:
                                      widget.pet
                                          .name,
                                  breed:
                                      widget.pet
                                          .breed,
                                  color:
                                      widget.pet
                                          .color,
                                  sex: widget
                                      .pet.sex,
                                  reporter: finderController
                                          .text
                                          .trim()
                                          .isEmpty
                                      ? 'QR Finder'
                                      : finderController
                                          .text
                                          .trim(),
                                  location:
                                      locationController
                                          .text
                                          .trim(),
                                  date:
                                      'September 25, 2026',
                                  description: notesController
                                          .text
                                          .trim()
                                          .isEmpty
                                      ? 'Pet identified through PawLink QR.'
                                      : notesController
                                          .text
                                          .trim(),
                                  photoLabel:
                                      'QR FINDER PHOTO',
                                  status:
                                      'Pending',
                                  qrScanned:
                                      true,
                                  petId: widget
                                      .pet.id,
                                );

                                reports.insert(
                                  0,
                                  report,
                                );

                                logActivity(
                                  'Received QR found-pet report',
                                  '${widget.pet.qrId} • ${widget.pet.name}',
                                );

                                setState(() {
                                  submitted =
                                      true;
                                });
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .send_outlined,
                              ),
                              label:
                                  const Text(
                                'Submit Report',
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACTIVITY LOG
// ============================================================

